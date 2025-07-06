// Générateur de données de test pour les Edge Functions

import { Account, Transaction } from './types.ts';

// Données de base pour la génération
const FRENCH_CATEGORIES = [
  'Alimentation et Restaurant',
  'Achats',
  'Transport',
  'Divertissement',
  'Factures et Services',
  'Santé',
  'Éducation',
  'Voyage',
  'Revenus',
  'Virement',
  'Épargne',
  'Assurance',
  'Impôts',
  'Logement'
];

const FRENCH_DESCRIPTIONS = {
  credit: [
    'Paiement de salaire',
    'Virement de Marie Dupont',
    'Virement de Paul Martin',
    'Remboursement assurance',
    'Remboursement impôts',
    'Virement épargne → courant',
    'Paiement freelance',
    'Bonus de performance',
    'Intérêts bancaires',
    'Dividendes investissement'
  ],
  debit: [
    'Achat épicerie Carrefour',
    'Restaurant Le Petit Bistro',
    'Achat en ligne Amazon',
    'Station essence Total',
    'Retrait DAB',
    'Café Starbucks',
    'Pharmacie du Centre',
    'Transport - Métro',
    'Facture électricité EDF',
    'Abonnement Netflix',
    'Achat librairie',
    'Paiement dentiste',
    'Achat vêtements Zara',
    'Livraison UberEats',
    'Parking centre-ville',
    'Facture téléphone Orange',
    'Assurance auto',
    'Courses Monoprix',
    'Boulangerie du coin',
    'Coiffeur'
  ]
};

const MERCHANTS = [
  'Carrefour',
  'Amazon',
  'Total',
  'Starbucks',
  'UberEats',
  'Zara',
  'McDonald\'s',
  'SNCF',
  'EDF',
  'Orange',
  'Netflix',
  'Spotify',
  'Fnac',
  'Décathlon',
  'Pharmacie',
  'Boulangerie',
  'Restaurant',
  'Parking',
  'Métro',
  'Taxi'
];

// Comptes de test par défaut
export const MOCK_ACCOUNTS: Account[] = [
  {
    id: 'acc_001',
    name: 'Compte Courant Principal',
    type: 'checking',
    balance: 2543.67,
    currency: 'EUR',
    iban: 'ES7921000813610123456789',
    bic: 'CAIXESBBXXX',
  },
  {
    id: 'acc_002',
    name: 'Compte Épargne',
    type: 'savings',
    balance: 15678.90,
    currency: 'EUR',
    iban: 'ES7921000813610987654321',
    bic: 'CAIXESBBXXX',
  },
  {
    id: 'acc_003',
    name: 'Compte Partagé',
    type: 'shared',
    balance: 4532.15,
    currency: 'EUR',
    iban: 'ES7921000813610111222333',
    bic: 'CAIXESBBXXX',
  },
  {
    id: 'acc_004',
    name: 'Compte Professionnel',
    type: 'business',
    balance: 12450.80,
    currency: 'EUR',
    iban: 'ES7921000813610444555666',
    bic: 'CAIXESBBXXX',
  }
];

// Fonction pour générer une transaction aléatoire
export function generateRandomTransaction(accountId?: string, daysAgo?: number): Transaction {
  const isCredit = Math.random() > 0.75; // 25% de chance d'être un crédit
  const now = new Date();
  
  // Date aléatoire dans les X derniers jours (défaut: 30 jours)
  const maxDaysAgo = daysAgo || Math.floor(Math.random() * 30);
  const date = new Date(now.getTime() - (maxDaysAgo * 24 * 60 * 60 * 1000));
  
  // Montant selon le type
  let amount: number;
  if (isCredit) {
    // Crédits: entre 100€ et 3000€
    amount = Math.floor(Math.random() * 2900) + 100;
  } else {
    // Débits: entre 5€ et 500€
    amount = -(Math.floor(Math.random() * 495) + 5);
  }
  
  // Description
  const descriptions = isCredit ? FRENCH_DESCRIPTIONS.credit : FRENCH_DESCRIPTIONS.debit;
  const description = descriptions[Math.floor(Math.random() * descriptions.length)];
  
  // Statut (90% completed, 8% pending, 2% failed)
  let status: Transaction['status'];
  const statusRand = Math.random();
  if (statusRand > 0.98) {
    status = 'FAILED';
  } else if (statusRand > 0.90) {
    status = 'PENDING';
  } else {
    status = 'COMPLETED';
  }
  
  // Catégorie
  const category = FRENCH_CATEGORIES[Math.floor(Math.random() * FRENCH_CATEGORIES.length)];
  
  // Référence
  const reference = `REF-${Math.random().toString(36).substring(2, 12).toUpperCase()}`;
  
  return {
    id: `txn-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
    accountId: accountId || 'acc_001',
    amount,
    currency: 'EUR',
    description,
    date: date.toISOString(),
    type: isCredit ? 'CREDIT' : 'DEBIT',
    status,
    category,
    reference,
    metadata: {
      merchant: MERCHANTS[Math.floor(Math.random() * MERCHANTS.length)],
      location: Math.random() > 0.5 ? 'Paris, France' : 'En ligne',
      paymentMethod: Math.random() > 0.5 ? 'Carte bancaire' : 'Virement',
    }
  };
}

// Fonction pour générer une liste de transactions
export function generateMockTransactions(count: number = 30, accountId?: string): Transaction[] {
  const transactions: Transaction[] = [];
  
  for (let i = 0; i < count; i++) {
    transactions.push(generateRandomTransaction(accountId, i));
  }
  
  // Trier par date décroissante
  return transactions.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
}

// Fonction pour appliquer des filtres aux transactions
export function applyTransactionFilters(
  transactions: Transaction[],
  filters: {
    type?: 'DEBIT' | 'CREDIT';
    status?: 'PENDING' | 'COMPLETED' | 'FAILED' | 'CANCELLED';
    startDate?: string;
    endDate?: string;
    category?: string;
    minAmount?: number;
    maxAmount?: number;
    search?: string;
  }
): Transaction[] {
  let filtered = [...transactions];
  
  if (filters.type) {
    filtered = filtered.filter(t => t.type === filters.type);
  }
  
  if (filters.status) {
    filtered = filtered.filter(t => t.status === filters.status);
  }
  
  if (filters.startDate) {
    const startDate = new Date(filters.startDate);
    filtered = filtered.filter(t => new Date(t.date) >= startDate);
  }
  
  if (filters.endDate) {
    const endDate = new Date(filters.endDate);
    filtered = filtered.filter(t => new Date(t.date) <= endDate);
  }
  
  if (filters.category) {
    filtered = filtered.filter(t => t.category?.toLowerCase().includes(filters.category!.toLowerCase()));
  }
  
  if (filters.minAmount !== undefined) {
    filtered = filtered.filter(t => Math.abs(t.amount) >= Math.abs(filters.minAmount!));
  }
  
  if (filters.maxAmount !== undefined) {
    filtered = filtered.filter(t => Math.abs(t.amount) <= Math.abs(filters.maxAmount!));
  }
  
  if (filters.search) {
    const searchLower = filters.search.toLowerCase();
    filtered = filtered.filter(t => 
      t.description.toLowerCase().includes(searchLower) ||
      t.category?.toLowerCase().includes(searchLower) ||
      t.reference?.toLowerCase().includes(searchLower)
    );
  }
  
  return filtered;
}

// Fonction pour paginer les résultats
export function paginateResults<T>(
  items: T[],
  page: number = 1,
  limit: number = 20
): {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
} {
  const total = items.length;
  const totalPages = Math.ceil(total / limit);
  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + limit;
  const data = items.slice(startIndex, endIndex);
  
  return {
    data,
    total,
    page,
    limit,
    totalPages
  };
}