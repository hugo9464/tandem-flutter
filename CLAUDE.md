# Tandem Flutter - Guide de développement Claude

## Vue d'ensemble du projet

Application Flutter de gestion bancaire avec backend Supabase et intégration exclusive à l'API GoCardless pour la récupération des données bancaires.

## Architecture

- **Frontend**: Flutter/Dart
- **Backend**: Supabase (PostgreSQL + Edge Functions)
- **API bancaire**: GoCardless (Bank Account Data API)
- **Authentification**: Supabase Auth

## Structure du projet

```
lib/
├── models/          # Modèles de données (GoCardless, Transaction, Account, etc.)
├── screens/         # Écrans de l'application
│   └── banking/     # Écrans de connexion bancaire GoCardless
├── services/        # Services (GoCardlessService, SupabaseService)
└── widgets/         # Widgets réutilisables

supabase/
└── functions/       # Edge Functions GoCardless uniquement
    ├── gocardless-auth/          # Authentification GoCardless
    ├── gocardless-institutions/  # Liste des banques
    ├── gocardless-requisition/   # Création de liens de connexion
    ├── gocardless-accounts/      # Récupération des comptes
    └── gocardless-transactions/  # Récupération des transactions
```

## Configuration Supabase

**URL du projet**: `https://olkwosfqonszrtvnrfgx.supabase.co`

### Edge Functions actives (GoCardless uniquement)

1. **gocardless-auth** - Authentification avec GoCardless
2. **gocardless-institutions** - Liste des banques disponibles par pays
3. **gocardless-requisition** - Création de liens de connexion bancaire
4. **gocardless-accounts** - Récupération des comptes après connexion
5. **gocardless-transactions** - Récupération des transactions

## API GoCardless (Implémentation principale)

### Configuration
- **URL**: `https://bankaccountdata.gocardless.com/api/v2`
- **Documentation**: Guide complet dans `docs/GOCARDLESS_INSTRUCTIONS.md`

### Variables d'environnement (supabase/.env)
```bash
GOCARDLESS_SECRET_ID=votre_secret_id_ici
GOCARDLESS_SECRET_KEY=votre_secret_key_ici
GOCARDLESS_BASE_URL=https://bankaccountdata.gocardless.com/api/v2
```

### Edge Functions GoCardless

1. **gocardless-auth** - Authentification avec GoCardless
2. **gocardless-institutions** - Liste des banques disponibles par pays
3. **gocardless-requisition** - Création de liens de connexion bancaire
4. **gocardless-accounts** - Récupération des comptes après connexion
5. **gocardless-transactions** - Récupération des transactions

### Services Flutter GoCardless

#### GoCardlessService (`lib/services/gocardless_service.dart`)

**Méthodes principales**:
- `authenticate()`: Authentification avec GoCardless
- `fetchInstitutions(country)`: Récupère les banques disponibles
- `createRequisition(institutionId, redirectUrl)`: Crée un lien de connexion
- `fetchAccounts(requisitionId)`: Récupère les comptes après connexion
- `fetchTransactions(accountId)`: Récupère les transactions d'un compte

**Flux de connexion**:
1. Authentification automatique lors du premier accès
2. Sélection d'une banque dans la liste des institutions
3. Redirection vers l'interface de la banque via WebView
4. Récupération des comptes une fois la connexion autorisée
5. Affichage des transactions pour chaque compte

### Interface utilisateur GoCardless

#### Écrans disponibles
- `BankSelectionScreen`: Sélection de la banque
- `BankConnectionScreen`: Connexion via WebView
- `BankAccountsScreen`: Liste des comptes récupérés
- `BankTransactionsScreen`: Transactions d'un compte

**Accès**: Bouton flottant "Banques" sur l'écran de sélection des tandems

### Modèles de données GoCardless (`lib/models/gocardless_models.dart`)

**Classes principales**:
- `BankInstitution`: Informations sur une banque
- `BankAccount`: Détails d'un compte bancaire
- `GoCardlessTransaction`: Transaction bancaire
- `GoCardlessRequisition`: Demande de connexion bancaire

## Services Flutter

### SupabaseService (`lib/services/supabase_service.dart`)

**Note**: Les méthodes bancaires (getTransactions, getAccounts) sont maintenant obsolètes.
Utiliser `GoCardlessService` pour toutes les opérations bancaires.

**Méthodes actives**:
- `getExpenses()`: Récupère les dépenses du tandem
- `addExpense()`: Ajoute une nouvelle dépense
- `deleteExpense()`: Supprime une dépense
- `getBalance()`: Calcule la balance entre les utilisateurs

## Débogage

### Logs des Edge Functions
Utiliser la commande MCP Supabase :
```
mcp__supabase__get_logs service=edge-function
```

### Erreurs communes GoCardless
- `GOCARDLESS_AUTH_FAILED`: Échec de l'authentification GoCardless
- `INSTITUTION_NOT_FOUND`: Banque non trouvée
- `REQUISITION_FAILED`: Échec de création du lien de connexion
- `ACCOUNT_ACCESS_DENIED`: Accès au compte refusé
- `TRANSACTION_FETCH_FAILED`: Échec de récupération des transactions

## Commandes utiles

### Déploiement des Edge Functions GoCardless
```bash
# Déployer les fonctions GoCardless
mcp__supabase__deploy_edge_function name=gocardless-auth files=[...]
mcp__supabase__deploy_edge_function name=gocardless-institutions files=[...]
mcp__supabase__deploy_edge_function name=gocardless-requisition files=[...]
mcp__supabase__deploy_edge_function name=gocardless-accounts files=[...]
mcp__supabase__deploy_edge_function name=gocardless-transactions files=[...]
```

### Surveillance et logs
```bash
# Obtenir les logs des edge functions
mcp__supabase__get_logs service=edge-function

# Vérifier les conseillers de sécurité
mcp__supabase__get_advisors type=security
```

## Notes de développement

1. **API uniquement GoCardless**: Banco.surf est obsolète et a été supprimé
2. **Flux de connexion bancaire**: Utilise WebView pour l'authentification sécurisée
3. **État des connexions**: Géré via les requisitions GoCardless
4. **CORS**: Toutes les edge functions GoCardless supportent les requêtes CORS
5. **Authentification**: Utilise les clés GoCardless (Secret ID + Secret Key)

## Sécurité

- Ne jamais exposer les clés GoCardless dans les logs
- Utiliser les variables d'environnement Supabase pour les secrets GoCardless
- Valider tous les paramètres d'entrée des Edge Functions
- Gérer les erreurs de manière appropriée sans exposer d'informations sensibles
- WebView sécurisé pour l'authentification bancaire

## Mise à jour de la documentation

**IMPORTANT**: Lorsque des informations importantes pour le développement sont découvertes ou que des règles/conventions sont établies, elles doivent être ajoutées à ce fichier CLAUDE.md pour servir de référence future. Cela inclut :

- Nouvelles configurations ou API découvertes
- Erreurs communes et leurs solutions
- Conventions de code spécifiques au projet
- Processus de débogage particuliers
- Toute information qui pourrait être utile pour comprendre ou maintenir le projet