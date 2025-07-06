# Tests de l'Application Tandem Flutter

Ce répertoire contient tous les tests pour l'application de gestion des dépenses entre couples Tandem.

## Structure des Tests

```
test/
├── models/                 # Tests des modèles de données
│   ├── expense_test.dart   # Tests du modèle Expense
│   └── transaction_test.dart # Tests du modèle Transaction
├── services/               # Tests des services
│   └── supabase_service_test.dart # Tests du service Supabase
├── widgets/                # Tests des widgets UI
│   ├── home_screen_test.dart     # Tests de l'écran d'accueil
│   ├── settings_screen_test.dart # Tests de l'écran de paramètres
│   └── network_status_test.dart  # Tests du widget de statut réseau
├── integration/            # Tests d'intégration
│   └── app_integration_test.dart # Tests de flux complets
├── test_helpers.dart       # Utilitaires et helpers pour les tests
└── README.md              # Cette documentation
```

## Types de Tests

### 1. Tests Unitaires (Unit Tests)
- **Modèles** : Validation de la sérialisation/désérialisation JSON, logique métier
- **Services** : Tests des appels API, gestion d'erreurs, calculs de balance
- **Logique** : Algorithmes de calcul des dépenses partagées

### 2. Tests de Widgets (Widget Tests)
- **Interface utilisateur** : Rendu correct des composants
- **Interactions** : Appuis, saisie de texte, navigation
- **États** : Loading, erreur, données vides

### 3. Tests d'Intégration (Integration Tests)
- **Flux complets** : Ajout d'une dépense de bout en bout
- **Navigation** : Transitions entre écrans
- **Persistance** : Sauvegarde et chargement des données

## Exécution des Tests

### Tous les tests
```bash
flutter test
```

### Tests spécifiques
```bash
# Tests unitaires uniquement
flutter test test/models/ test/services/

# Tests de widgets uniquement
flutter test test/widgets/

# Tests d'intégration uniquement
flutter test test/integration/

# Un test spécifique
flutter test test/models/expense_test.dart
```

### Avec couverture de code
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Script de test personnalisé
```bash
dart test_runner.dart                    # Tests sans intégration
dart test_runner.dart --integration      # Tous les tests
```

## Couverture de Test

### Modèles de Données
- ✅ Sérialisation JSON (fromJson/toJson)
- ✅ Validation des types de données
- ✅ Gestion des cas limites (montants négatifs, caractères spéciaux)
- ✅ Formats de dates variés
- ✅ Montants en différents formats (string, double)

### Services
- ✅ Appels API réussis
- ✅ Gestion d'erreurs HTTP (404, 500, timeout)
- ✅ Calculs de balance entre couples
- ✅ Ajout/suppression de dépenses
- ✅ Validation des données d'entrée

### Interface Utilisateur
- ✅ Rendu des composants
- ✅ États de chargement
- ✅ Validation des formulaires
- ✅ Navigation entre écrans
- ✅ Gestion des interactions utilisateur
- ✅ Affichage des messages d'erreur

### Intégration
- ✅ Flux d'ajout de dépense complet
- ✅ Navigation entre onglets
- ✅ Gestion d'état entre écrans
- ✅ Récupération des données au démarrage

## Bonnes Pratiques Testées

### Gestion d'Erreurs
- Erreurs réseau (perte de connexion, timeout)
- Données manquantes ou malformées
- Validation des entrées utilisateur

### Performance
- Temps de chargement des écrans
- Navigation rapide entre onglets
- Gestion de listes longues

### Accessibilité
- Labels sémantiques
- Navigation au clavier
- Contraste des couleurs

### Sécurité
- Validation des données côté client
- Gestion sécurisée des tokens
- Protection contre l'injection de code

## Cas de Test Spéciaux

### Dépenses
- Montants avec décimales (0.01, 999.99)
- Descriptions avec caractères spéciaux (émojis, accents)
- Dates dans différents formats
- Utilisateurs inconnus

### Balance
- Dépenses équilibrées (50/50)
- Un utilisateur paie tout
- Aucune dépense
- Très grandes sommes

### Interface
- Écrans vides (pas de données)
- États de chargement
- Erreurs réseau
- Validation de formulaires

## Mocks et Fixtures

### Données de Test
- Comptes bancaires factices
- Dépenses d'exemple
- Réponses API mockées
- Utilisateurs de test

### Services Mockés
- Client HTTP (succès/échec)
- Base de données Supabase
- Authentification
- Stockage local

## Maintenance des Tests

### Ajout de Nouveaux Tests
1. Suivre la structure existante
2. Utiliser les helpers dans `test_helpers.dart`
3. Nommer clairement les tests
4. Documenter les cas complexes

### Mise à Jour
- Synchroniser avec les changements de l'API
- Adapter aux nouvelles fonctionnalités
- Maintenir la couverture de code > 80%

### Débogage
- Utiliser `debugDumpApp()` pour l'arbre de widgets
- `tester.pump()` vs `tester.pumpAndSettle()`
- Vérifier les logs de test pour les erreurs silencieuses

## Configuration CI/CD

Les tests sont conçus pour s'exécuter dans un environnement CI/CD :

```yaml
# Exemple GitHub Actions
- name: Run tests
  run: flutter test --coverage
  
- name: Check coverage
  run: |
    dart pub global activate coverage
    dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.packages --report-on=lib
```

## Ressources

- [Documentation Flutter Testing](https://flutter.dev/docs/testing)
- [Widget Testing](https://flutter.dev/docs/cookbook/testing/widget)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)
- [Mockito Package](https://pub.dev/packages/mockito)