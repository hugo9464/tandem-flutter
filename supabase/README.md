# Supabase Edge Functions pour Tandem Flutter

Ce dossier contient les Edge Functions Supabase pour l'application Tandem Flutter, remplaçant l'API tandem-pwa.

## Structure du projet

```
supabase/
├── functions/
│   ├── accounts-direct/    # Récupération des comptes bancaires
│   │   └── index.ts
│   ├── transactions/       # Gestion des transactions
│   │   └── index.ts
│   └── test-transactions/  # Données de test pour les transactions
│       └── index.ts
├── migrations/
│   └── 20240101000000_init_tandem_schema.sql
├── config.toml            # Configuration Supabase
└── README.md
```

## Edge Functions disponibles

### 1. `accounts-direct`
- **URL**: `/functions/v1/accounts-direct`
- **Méthode**: GET
- **Description**: Récupère la liste des comptes bancaires depuis l'API Banco.surf ou retourne des données de test en cas d'erreur
- **Réponse**: Liste des comptes avec ID, nom, type, solde, devise, IBAN, BIC

### 2. `transactions`
- **URL**: `/functions/v1/transactions`
- **Méthode**: GET
- **Paramètres de requête**:
  - `accountId`: ID du compte (optionnel)
  - `startDate`: Date de début (ISO 8601)
  - `endDate`: Date de fin (ISO 8601)
  - `type`: DEBIT ou CREDIT
  - `status`: PENDING, COMPLETED, ou FAILED
  - `category`: Catégorie de transaction
  - `page`: Numéro de page (défaut: 1)
  - `limit`: Nombre d'éléments par page (défaut: 20)
- **Description**: Récupère les transactions avec filtrage et pagination
- **Réponse**: Liste paginée des transactions

### 3. `test-transactions`
- **URL**: `/functions/v1/test-transactions`
- **Méthode**: GET
- **Description**: Génère des transactions de test pour le développement
- **Réponse**: Liste de 25 transactions de test variées

## Installation et déploiement

### Prérequis
- Supabase CLI installé (`npm install -g supabase`)
- Compte Supabase actif

### Développement local

1. **Initialiser Supabase localement** :
```bash
supabase start
```

2. **Déployer les fonctions localement** :
```bash
supabase functions serve
```

3. **Tester une fonction** :
```bash
curl http://localhost:54321/functions/v1/accounts-direct
```

### Déploiement en production

1. **Se connecter à Supabase** :
```bash
supabase login
```

2. **Lier le projet** :
```bash
supabase link --project-ref YOUR_PROJECT_REF
```

3. **Déployer les fonctions** :
```bash
supabase functions deploy accounts-direct
supabase functions deploy transactions
supabase functions deploy test-transactions
```

4. **Déployer les migrations** :
```bash
supabase db push
```

## Configuration

### Variables d'environnement

Les fonctions utilisent ces variables d'environnement :

- `BANCO_SURF_API_BASE_URL`: URL de base de l'API Banco.surf (défaut: https://banco.surf)
- `BANCO_SURF_API_TOKEN`: Token d'authentification pour l'API Banco.surf

### Configuration dans Supabase Dashboard

1. Aller dans **Settings** > **Edge Functions**
2. Ajouter les variables d'environnement :
   - `BANCO_SURF_API_BASE_URL`
   - `BANCO_SURF_API_TOKEN`

## Utilisation dans Flutter

L'application Flutter utilise ces fonctions via la classe `SupabaseService` :

```dart
// Récupérer les comptes
final accounts = await SupabaseService.getAccounts();

// Récupérer les transactions avec filtres
final transactions = await SupabaseService.getTransactions(
  accountId: 'acc_001',
  filters: TransactionFilters(
    dateFrom: DateTime.now().subtract(Duration(days: 30)),
    type: TransactionType.debit,
  ),
);

// Récupérer les transactions de test
final testTransactions = await SupabaseService.getTestTransactions();
```

## Fonctionnalités

### Gestion d'erreur et fallback
- Si l'API Banco.surf n'est pas disponible, les fonctions retournent automatiquement des données de test
- Gestion des erreurs CORS pour les applications web
- Logs détaillés pour le débogage

### Performance
- Cache HTTP configuré (5 minutes pour les comptes, 1 minute pour les transactions)
- Compression des réponses
- Pagination optimisée

### Sécurité
- Headers CORS appropriés
- Validation des paramètres d'entrée
- Gestion sécurisée des tokens API

## Monitoring

### Logs
Consultez les logs des fonctions dans le dashboard Supabase :
1. **Functions** > **Edge Functions**
2. Cliquez sur une fonction
3. Onglet **Logs**

### Métriques
- Nombre d'invocations
- Temps de réponse moyen
- Taux d'erreur
- Utilisation de la bande passante

## Développement

### Ajouter une nouvelle fonction

1. Créer le dossier :
```bash
mkdir supabase/functions/ma-nouvelle-fonction
```

2. Créer le fichier index.ts :
```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req: Request) => {
  // Votre code ici
});
```

3. Déployer :
```bash
supabase functions deploy ma-nouvelle-fonction
```

### Tests

Pour tester les fonctions localement :

```bash
# Démarrer Supabase local
supabase start

# Tester avec curl
curl -X GET \
  'http://localhost:54321/functions/v1/accounts-direct' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```