# Plan Firebase pour Ablette

## Services a activer

1. Firebase Auth
   - Email / mot de passe pour commencer.
   - Google et Apple plus tard si l'app sort sur stores.

2. Cloud Firestore
   - `users/{uid}` pour le profil.
   - `users/{uid}/vehicles/{vehicleId}` pour le garage.
   - `users/{uid}/vehicles/{vehicleId}/maintenanceRecords/{ruleId}` pour les entretiens faits.

3. Firebase Cloud Messaging
   - Utile pour les rappels serveur.
   - Les notifications locales suffisent pour un premier MVP mobile.

## Branchement Flutter

Commandes prevues quand le projet Firebase existe :

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
flutter pub add firebase_core firebase_auth cloud_firestore
```

Ensuite :

- Initialiser Firebase dans `lib/main.dart`.
- Remplacer `GarageStore.seeded()` par un repository Firestore.
- Garder les modeles `Vehicle`, `MaintenanceRule` et `MaintenanceRecord`.

## Donnees vehicule

La recherche par plaque n'est pas retenue pour le MVP.

Sources a etudier :

- ADEME Car Labelling pour marque, modele, CNIT/TVV, energie et emissions.
- Saisie assistee quand les donnees ouvertes ne suffisent pas.

## Notifications

Premier niveau :

- Rappel mensuel pour saisir le kilometrage.
- Rappel local quand un entretien est proche ou depasse.

Deuxieme niveau :

- Cloud Functions ou serveur planifie.
- Push FCM si l'utilisateur change de telephone ou ne lance pas l'app.
