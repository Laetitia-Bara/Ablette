# Ablette — Interface React

Le lot 1 permet de consulter les véhicules et d’en créer un. Les données viennent exclusivement de l’API ; aucun véhicule de démonstration n’est injecté dans l’application.

## Développement

Prérequis : Node.js 24 LTS et backend démarré sur `http://127.0.0.1:8080`.

```sh
npm ci
npm run dev
```

Ouvrir `http://127.0.0.1:5173/garage`. Vite transmet `/api` au backend ; le navigateur utilise la même origine. Les pages `/garage` et `/garage/new` sont les deux parcours disponibles.

```sh
npm test
npm run build
```

Sur Windows, utiliser `npm.cmd` si la stratégie PowerShell bloque `npm.ps1`. Si Node ne reconnaît pas le certificat de l’environnement, utiliser le magasin de certificats système (`$env:NODE_OPTIONS='--use-system-ca'`) sans désactiver la vérification TLS.

## Structure

- `src/api/vehicles.ts` : DTO TypeScript, appels REST et erreurs ProblemDetail.
- `src/pages/GaragePage.tsx` : lecture, chargement, garage vide, erreurs et cartes.
- `src/pages/NewVehiclePage.tsx` : formulaire, validation et création.
- `src/components/AppLayout.tsx` : navigation et cadre adaptatif.
- `src/test/App.test.tsx` : parcours de création, relecture, erreurs réseau et validation. Les réponses HTTP de ces tests de composants sont simulées ; les tests de persistance de la base relèvent du backend.

TanStack Query conserve la liste uniquement en mémoire et l’invalide après une création. Les réponses API ne sont pas stockées hors ligne. Les règles métier et la validation définitive restent du ressort de Java.

L’interface prévoit des cartes en une, deux ou trois colonnes et un formulaire sur une route dédiée au mobile. Le formulaire est chargé à la demande. Le conteneur Nginx s’exécute sans privilèges sur le port 8080, transmet `/api/` au service `backend:8080` et permet le rechargement direct des routes React.

La PWA installable, les comptes, la maintenance et les documents sont prévus dans les lots suivants. Aucun service worker ni cache de données personnelles n’est installé par ce lot.
