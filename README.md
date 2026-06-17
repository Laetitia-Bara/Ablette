# Ablette

Ablette est un compagnon mobile pour suivre l'entretien de vehicules non connectes.

## MVP actuel

- Garage local avec deux vehicules d'exemple.
- Ajout manuel ou depuis une petite base de modeles.
- Generation de rappels d'entretien selon kilometrage et periodicite.
- Mise a jour du kilometrage.
- Marquage d'un entretien comme fait.

## Vision produit

- Compte utilisateur avec Firebase Auth.
- Garage synchronise avec Firestore.
- Recherche vehicule via donnees ouvertes quand c'est possible, puis saisie assistee.
- Rappels mensuels de kilometrage.
- Notifications d'entretien sur telephone.

## Lancer

```powershell
flutter pub get
flutter run -d chrome
```

## Firebase

Le projet Firebase n'est pas encore cree. La premiere version garde donc les donnees en memoire.
Voir `docs/firebase_setup.md` pour le plan de branchement.
