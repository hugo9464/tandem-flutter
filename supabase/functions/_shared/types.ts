// Types partagés pour les Edge Functions Supabase

export interface Account {
  id: string;
  name: string;
  type: 'checking' | 'savings' | 'shared' | 'business';
  balance: number;
  currency: string;
  iban?: string;
  bic?: string;
}

export interface Transaction {
  id: string;
  accountId: string;
  amount: number;
  currency: string;
  description: string;
  date: string; // ISO 8601 string
  type: 'DEBIT' | 'CREDIT';
  status: 'PENDING' | 'COMPLETED' | 'FAILED' | 'CANCELLED';
  category?: string;
  reference?: string;
  metadata?: Record<string, any>;
}

export interface TransactionFilters {
  accountId?: string;
  startDate?: string; // ISO 8601 string
  endDate?: string; // ISO 8601 string
  type?: 'DEBIT' | 'CREDIT';
  status?: 'PENDING' | 'COMPLETED' | 'FAILED' | 'CANCELLED';
  category?: string;
  minAmount?: number;
  maxAmount?: number;
  page?: number;
  limit?: number;
  search?: string;
}

export interface TransactionResponse {
  data: Transaction[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface BancoSurfApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface ApiError {
  message: string;
  code?: string;
  details?: any;
}

// Constantes
export const TRANSACTION_TYPES = ['DEBIT', 'CREDIT'] as const;
export const TRANSACTION_STATUSES = ['PENDING', 'COMPLETED', 'FAILED', 'CANCELLED'] as const;
export const ACCOUNT_TYPES = ['checking', 'savings', 'shared', 'business'] as const;

export const DEFAULT_PAGE_SIZE = 20;
export const MAX_PAGE_SIZE = 100;

// Utilitaires de validation
export function isValidTransactionType(type: string): type is Transaction['type'] {
  return TRANSACTION_TYPES.includes(type as any);
}

export function isValidTransactionStatus(status: string): status is Transaction['status'] {
  return TRANSACTION_STATUSES.includes(status as any);
}

export function isValidAccountType(type: string): type is Account['type'] {
  return ACCOUNT_TYPES.includes(type as any);
}

// Fonction pour créer une réponse d'erreur standardisée
export function createErrorResponse(message: string, code?: string, details?: any): BancoSurfApiResponse<null> {
  return {
    success: false,
    error: message,
    data: null,
    ...(code && { code }),
    ...(details && { details })
  };
}

// Fonction pour créer une réponse de succès standardisée
export function createSuccessResponse<T>(data: T): BancoSurfApiResponse<T> {
  return {
    success: true,
    data
  };
}