# Guide d'implémentation Flutter + GoCardless + Supabase Edge Functions

## Vue d'ensemble de l'architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │◄──►│ Supabase Edge    │◄──►│  GoCardless     │
│                 │    │ Functions        │    │  Bank API       │
│  - UI Banques   │    │  - Auth GoCard   │    │  - Connexion    │
│  - Sélection    │    │  - Proxy API     │    │  - Transactions │
│  - Transactions │    │  - Sécurité      │    │  - Comptes      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

**Pourquoi cette architecture ?**
- ✅ **Sécurité** : Les secrets GoCardless restent côté serveur
- ✅ **CORS** : Contournement des restrictions cross-origin
- ✅ **Flexibilité** : Logique métier centralisée
- ✅ **Scalabilité** : Edge functions auto-scaling

---

## Prérequis

### 1. Compte GoCardless
1. Créer un compte sur [bankaccountdata.gocardless.com](https://bankaccountdata.gocardless.com)
2. Aller dans **Developers > User Secrets**
3. Créer de nouveaux secrets et noter :
   - `secret_id`
   - `secret_key`

### 2. Projet Supabase
- Projet Supabase existant avec Edge Functions activées
- CLI Supabase installé : `npm install -g supabase`

### 3. Dependencies Flutter
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  supabase_flutter: ^2.0.0
  url_launcher: ^6.2.2
  webview_flutter: ^4.4.2
  provider: ^6.1.1
```

---

## Configuration Supabase

### 1. Variables d'environnement

Créer/modifier `.env` dans votre projet Supabase :

```bash
# .env
GOCARDLESS_SECRET_ID=votre_secret_id_ici
GOCARDLESS_SECRET_KEY=votre_secret_key_ici
GOCARDLESS_BASE_URL=https://bankaccountdata.gocardless.com/api/v2
```

### 2. Structure des Edge Functions

```
supabase/
└── functions/
    ├── gocardless-auth/
    │   └── index.ts
    ├── gocardless-institutions/
    │   └── index.ts
    ├── gocardless-requisition/
    │   └── index.ts
    ├── gocardless-accounts/
    │   └── index.ts
    └── gocardless-transactions/
        └── index.ts
```

---

## Edge Functions Supabase

### 1. Fonction d'authentification GoCardless

**Fichier** : `supabase/functions/gocardless-auth/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface GoCardlessTokenResponse {
  access: string;
  access_expires: number;
  refresh: string;
  refresh_expires: number;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { secret_id, secret_key } = Deno.env.toObject();
    
    if (!secret_id || !secret_key) {
      throw new Error('GoCardless secrets not configured');
    }

    const response = await fetch(`${Deno.env.get('GOCARDLESS_BASE_URL')}/token/new/`, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        secret_id: secret_id,
        secret_key: secret_key,
      }),
    });

    if (!response.ok) {
      throw new Error(`GoCardless auth failed: ${response.status}`);
    }

    const tokenData: GoCardlessTokenResponse = await response.json();

    return new Response(
      JSON.stringify({
        success: true,
        data: tokenData,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});
```

### 2. Fonction pour lister les banques

**Fichier** : `supabase/functions/gocardless-institutions/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const country = url.searchParams.get('country') || 'FR';
    const accessToken = req.headers.get('x-gocardless-token');

    if (!accessToken) {
      throw new Error('Access token required');
    }

    const response = await fetch(
      `${Deno.env.get('GOCARDLESS_BASE_URL')}/institutions/?country=${country}`,
      {
        headers: {
          'Accept': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to fetch institutions: ${response.status}`);
    }

    const institutions = await response.json();

    return new Response(
      JSON.stringify({
        success: true,
        data: institutions,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});
```

### 3. Fonction pour créer une requisition

**Fichier** : `supabase/functions/gocardless-requisition/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const accessToken = req.headers.get('x-gocardless-token');
    if (!accessToken) {
      throw new Error('Access token required');
    }

    const body = await req.json();
    const { institution_id, redirect_url, reference, user_language = 'FR' } = body;

    if (!institution_id || !redirect_url) {
      throw new Error('institution_id and redirect_url are required');
    }

    const response = await fetch(
      `${Deno.env.get('GOCARDLESS_BASE_URL')}/requisitions/`,
      {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          institution_id,
          redirect: redirect_url,
          reference: reference || `flutter_${Date.now()}`,
          user_language,
        }),
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Failed to create requisition: ${response.status} - ${errorText}`);
    }

    const requisition = await response.json();

    return new Response(
      JSON.stringify({
        success: true,
        data: requisition,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});
```

### 4. Fonction pour récupérer les comptes

**Fichier** : `supabase/functions/gocardless-accounts/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const requisitionId = url.searchParams.get('requisition_id');
    const accessToken = req.headers.get('x-gocardless-token');

    if (!accessToken || !requisitionId) {
      throw new Error('Access token and requisition_id required');
    }

    // 1. Récupérer la requisition pour obtenir les IDs des comptes
    const requisitionResponse = await fetch(
      `${Deno.env.get('GOCARDLESS_BASE_URL')}/requisitions/${requisitionId}/`,
      {
        headers: {
          'Accept': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
      }
    );

    if (!requisitionResponse.ok) {
      throw new Error(`Failed to fetch requisition: ${requisitionResponse.status}`);
    }

    const requisition = await requisitionResponse.json();

    // 2. Récupérer les détails de chaque compte
    const accountsDetails = await Promise.all(
      requisition.accounts.map(async (accountId: string) => {
        const accountResponse = await fetch(
          `${Deno.env.get('GOCARDLESS_BASE_URL')}/accounts/${accountId}/details/`,
          {
            headers: {
              'Accept': 'application/json',
              'Authorization': `Bearer ${accessToken}`,
            },
          }
        );

        if (accountResponse.ok) {
          const accountData = await accountResponse.json();
          return {
            id: accountId,
            ...accountData.account,
          };
        }
        return { id: accountId, error: 'Failed to fetch details' };
      })
    );

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          requisition,
          accounts: accountsDetails,
        },
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});
```

### 5. Fonction pour récupérer les transactions

**Fichier** : `supabase/functions/gocardless-transactions/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const accountId = url.searchParams.get('account_id');
    const accessToken = req.headers.get('x-gocardless-token');

    if (!accessToken || !accountId) {
      throw new Error('Access token and account_id required');
    }

    const response = await fetch(
      `${Deno.env.get('GOCARDLESS_BASE_URL')}/accounts/${accountId}/transactions/`,
      {
        headers: {
          'Accept': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to fetch transactions: ${response.status}`);
    }

    const transactions = await response.json();

    return new Response(
      JSON.stringify({
        success: true,
        data: transactions,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});
```

---

## Application Flutter

### 1. Configuration Supabase

**Fichier** : `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/bank_connection_screen.dart';
import 'services/gocardless_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'VOTRE_SUPABASE_URL',
    anonKey: 'VOTRE_SUPABASE_ANON_KEY',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoCardlessService(),
      child: MaterialApp(
        title: 'Banking App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: BankConnectionScreen(),
      ),
    );
  }
}
```

### 2. Service GoCardless

**Fichier** : `lib/services/gocardless_service.dart`

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bank_models.dart';

class GoCardlessService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _accessToken;
  List<BankInstitution> _institutions = [];
  List<BankAccount> _accounts = [];
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get accessToken => _accessToken;
  List<BankInstitution> get institutions => _institutions;
  List<BankAccount> get accounts => _accounts;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // 1. Authentification GoCardless
  Future<bool> authenticate() async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _supabase.functions.invoke(
        'gocardless-auth',
        method: HttpMethod.post,
      );

      if (response.data['success'] == true) {
        _accessToken = response.data['data']['access'];
        return true;
      } else {
        _setError(response.data['error'] ?? 'Authentication failed');
        return false;
      }
    } catch (e) {
      _setError('Authentication error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 2. Récupérer les banques disponibles
  Future<void> fetchInstitutions({String country = 'FR'}) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await _supabase.functions.invoke(
        'gocardless-institutions',
        method: HttpMethod.get,
        queryParameters: {'country': country},
        headers: {'x-gocardless-token': _accessToken!},
      );

      if (response.data['success'] == true) {
        _institutions = (response.data['data'] as List)
            .map((json) => BankInstitution.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        _setError(response.data['error']);
      }
    } catch (e) {
      _setError('Failed to fetch institutions: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 3. Créer une requisition pour connecter une banque
  Future<String?> createRequisition(
    String institutionId,
    String redirectUrl,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await _supabase.functions.invoke(
        'gocardless-requisition',
        method: HttpMethod.post,
        headers: {'x-gocardless-token': _accessToken!},
        body: {
          'institution_id': institutionId,
          'redirect_url': redirectUrl,
          'reference': 'flutter_${DateTime.now().millisecondsSinceEpoch}',
          'user_language': 'FR',
        },
      );

      if (response.data['success'] == true) {
        final requisition = response.data['data'];
        return requisition['link']; // URL pour rediriger l'utilisateur
      } else {
        _setError(response.data['error']);
        return null;
      }
    } catch (e) {
      _setError('Failed to create requisition: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 4. Récupérer les comptes après connexion
  Future<void> fetchAccounts(String requisitionId) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await _supabase.functions.invoke(
        'gocardless-accounts',
        method: HttpMethod.get,
        queryParameters: {'requisition_id': requisitionId},
        headers: {'x-gocardless-token': _accessToken!},
      );

      if (response.data['success'] == true) {
        final accountsData = response.data['data']['accounts'] as List;
        _accounts = accountsData
            .map((json) => BankAccount.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        _setError(response.data['error']);
      }
    } catch (e) {
      _setError('Failed to fetch accounts: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 5. Récupérer les transactions