# Lot 1 — Fondations et garage persistant

Le périmètre est volontairement limité : créer un véhicule et relire ses informations depuis PostgreSQL. Les entretiens, les relevés successifs, les comptes, les justificatifs et l'installation PWA appartiennent aux lots suivants.

## Comprendre le chemin d'une création

1. React récupère les champs et envoie un `POST /api/v1/vehicles`.
2. `VehicleController` transforme le JSON en `CreateVehicleRequest` et déclenche la validation.
3. `VehicleService` vérifie les contraintes métier, notamment la limite d'année calculée avec `Clock`.
4. `VehicleRepository`, une interface Spring Data JPA, enregistre l'entité `Vehicle` dans PostgreSQL.
5. La transaction est validée et `VehicleResponse` expose les champs utiles au navigateur.
6. TanStack Query invalide la liste et effectue une nouvelle lecture. Un rechargement du navigateur redemande les véhicules à la base.

## Classes Java créées

| Classe | Pourquoi elle existe |
|---|---|
| `AbletteApplication` | Démarre Spring Boot |
| `Vehicle` | Modèle de persistance JPA, table et colonnes |
| `Fuel` | Ensemble explicite des énergies acceptées |
| `CreateVehicleRequest` | DTO d'entrée et contraintes de forme |
| `VehicleResponse` | DTO de sortie, distinct de l'entité |
| `VehicleController` | Routes REST et codes HTTP |
| `VehicleService` | Cas d'usage, règle d'année et transactions |
| `VehicleRepository` | Lecture et écriture via Spring Data JPA |
| `VehicleNotFoundException` | Signale un identifiant absent |
| `InvalidVehicleException` | Signale une règle métier non respectée |
| `ApiExceptionHandler` | Traduit les erreurs en réponses REST cohérentes |
| `ApplicationConfiguration` | Fournit l'horloge Java injectable |
| `SecurityConfiguration` | Ouvre explicitement le développement local et ferme les autres profils |

Un `record` Java décrit ici un DTO immuable. Une entité JPA possède une identité et un cycle de vie géré par Hibernate. Le service ne renvoie pas l'entité au navigateur : le contrat HTTP peut ainsi évoluer sans exposer les détails de persistance.

`@Transactional` garantit une création complète ou un échec ; une validation refusée ne doit pas laisser un véhicule partiellement enregistré. `@Transactional(readOnly = true)` exprime les usages de lecture. Flyway versionne le schéma SQL ; `ddl-auto=validate` vérifie le schéma au démarrage sans le modifier automatiquement.

## Tests et démonstration

Les tests Java couvrent la limite d'année avec une date fixe, le nettoyage des textes, les champs requis, le compteur, les réponses REST, le JSON strict et le profil de sécurité fermé. Les tests d'intégration utilisent un véritable PostgreSQL jetable via Testcontainers, appliquent Flyway et vérifient les routes, les contraintes SQL et OpenAPI.

Les tests React vérifient chargement, garage vide, création, relecture, erreurs de connexion et messages par champ. Ils simulent HTTP pour tester l'interface ; ils ne constituent pas une preuve de persistance PostgreSQL.

La preuve de persistance complète est : créer dans l'interface, retrouver le véhicule par son identifiant via l'API, redémarrer PostgreSQL et le backend sans supprimer le volume, puis retrouver exactement le même véhicule. Le script `scripts/verify-persistence.mjs` automatise cette séquence avec des informations fictives.

Vérifications exécutées le 21 octobre 2026 :

| Vérification | Résultat observé |
|---|---|
| Tests Java : services, validation, MVC et profil de sécurité | 20 réussis, aucun échec ni test ignoré |
| Compilation et packaging Java 21 | Réussis |
| Vitest / React Testing Library | 5 tests réussis |
| Compilation TypeScript et build Vite | Réussis |
| Analyse des dépendances npm à l'installation | Aucune vulnérabilité signalée |
| Création de véhicules dans Chrome à 375, 768 et 1440 px | 3 créations réelles via POST, puis relectures réussies |
| Migration Flyway et validation Hibernate sur PostgreSQL 17.11 | Réussies |
| Redémarrage du backend et du serveur PostgreSQL local | 4 véhicules, identifiants et tous les champs, dates comprises, identiques après le correctif |
| Contrôles HTTP sur PostgreSQL réel | 6 entrées invalides refusées en 400, sans enregistrement ; OpenAPI et Swagger en 200 |
| Garage et formulaire à 375, 768 et 1440 px | Aucun débordement horizontal constaté ; captures conservées |
| Docker Compose | Configuration analysée avec succès ; lancement complet en attente du moteur Docker |
| Testcontainers PostgreSQL | Exécution tentée, bloquée par Docker Desktop indisponible ; aucun contournement de ces tests |
| Workflow GitHub Actions | Configuré ; aucune exécution distante revendiquée avant publication de la branche |

La démonstration locale utilise un PostgreSQL 17.11 portable, isolé dans `.local/`, pendant la remise en état de Docker Desktop. Elle conserve la même stack et les mêmes migrations. Elle ne remplace pas la validation encore attendue du lancement Compose et des 12 scénarios Testcontainers.

Captures : [garage PC](screenshots/garage-1440.png), [garage tablette](screenshots/garage-768.png), [garage smartphone](screenshots/garage-375.png), [formulaire smartphone](screenshots/form-375.png). Les informations présentées sont fictives.

Un point concret rencontré pendant cette vérification : `Instant` accepte les nanosecondes, alors que PostgreSQL conserve ici les microsecondes. Le service normalise donc `createdAt` avant sauvegarde ; un test de régression évite qu'une même date change légèrement entre la réponse de création et une relecture.

## Savoir présenter ce lot en entretien

- Expliquer pourquoi un DTO est différent d'une entité JPA et pourquoi l'API n'expose pas celle-ci.
- Montrer la différence entre validation de formulaire, Bean Validation et règle métier de service.
- Expliquer le rôle de `Clock` pour un test stable l'année prochaine.
- Montrer comment Flyway et Hibernate se complètent, et où les données survivent à un redémarrage.
- Expliquer la différence de précision entre `Instant` et le stockage PostgreSQL, et le test ajouté pour la maîtriser.
- Distinguer test unitaire avec Mockito, test MVC, test de composants React et intégration PostgreSQL.
- Décrire honnêtement le périmètre : un garage local est livré ; les contrôles entre comptes arrivent au lot 4.

Le prototype Flutter et ses fichiers locaux sont conservés dans `prototype/flutter/`, et son état Git initial reste accessible par le tag `archive/flutter-prototype-2026-10-21`. Aucun véhicule fictif n'a été migré depuis Flutter.
