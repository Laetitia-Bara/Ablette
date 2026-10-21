import { spawnSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { parseEnv } from 'node:util';

const root = fileURLToPath(new URL('../', import.meta.url));
const localConfig = await readFile(new URL('../.env', import.meta.url), 'utf8')
  .then(parseEnv)
  .catch((error) => {
    if (error.code === 'ENOENT') return {};
    throw error;
  });
const baseUrl = process.env.ABLETTE_API_URL ?? `http://127.0.0.1:${localConfig.API_PORT || '8080'}`;
const pause = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds));

async function waitForApi() {
  for (let attempt = 0; attempt < 60; attempt += 1) {
    try {
      const response = await fetch(`${baseUrl}/actuator/health`, { signal: AbortSignal.timeout(2000) });
      if (response.ok) return;
    } catch {
      // PostgreSQL and the application need a few seconds to restart.
    }
    await pause(2000);
  }
  throw new Error('API indisponible après l’attente de redémarrage. Vérifiez docker compose logs backend.');
}

await waitForApi();
const request = {
  nickname: 'DÉMO — persistance', brand: 'Renault', model: 'Clio', year: 2018,
  engine: '1.2 essence', fuel: 'PETROL', currentMileage: 85000,
};
const createdResponse = await fetch(`${baseUrl}/api/v1/vehicles`, {
  method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(request),
});
if (createdResponse.status !== 201) {
  throw new Error(`Création refusée : ${createdResponse.status} ${await createdResponse.text()}`);
}
const created = await createdResponse.json();
for (const field of Object.keys(request)) {
  if (created[field] !== request[field]) throw new Error(`Valeur incorrecte à la création : ${field}`);
}
console.log(`Véhicule fictif créé : ${created.id}. Redémarrage de PostgreSQL et du backend…`);
const restart = spawnSync('docker', ['compose', 'restart', 'db', 'backend'], {
  cwd: root, stdio: 'inherit', shell: false,
});
if (restart.error) throw restart.error;
if (restart.status !== 0) throw new Error('Redémarrage Docker impossible.');
await waitForApi();
const response = await fetch(`${baseUrl}/api/v1/vehicles/${created.id}`);
if (!response.ok) throw new Error(`Véhicule absent après redémarrage : HTTP ${response.status}`);
const reloaded = await response.json();
for (const field of ['id', ...Object.keys(request)]) {
  if (reloaded[field] !== created[field]) throw new Error(`Valeur différente après redémarrage : ${field}`);
}
console.log(`Persistance vérifiée : ${reloaded.nickname}, ${reloaded.currentMileage} km, même identifiant.`);
console.log('Ce véhicule fictif est conservé dans votre base locale de développement.');
