-- Migration initiale pour le projet Tandem
-- Création des tables pour les comptes et transactions

-- Activation des extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table des comptes bancaires
CREATE TABLE IF NOT EXISTS accounts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  external_id TEXT UNIQUE, -- ID depuis l'API externe (Banco.surf)
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('checking', 'savings', 'shared', 'business')),
  balance DECIMAL(12,2) NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'EUR',
  iban TEXT,
  bic TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des transactions
CREATE TABLE IF NOT EXISTS transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  external_id TEXT UNIQUE, -- ID depuis l'API externe
  account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
  amount DECIMAL(12,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'EUR',
  description TEXT NOT NULL,
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('DEBIT', 'CREDIT')),
  status TEXT NOT NULL CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED')),
  category TEXT,
  reference TEXT,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category);

-- Index composé pour les requêtes fréquentes
CREATE INDEX IF NOT EXISTS idx_transactions_account_date ON transactions(account_id, transaction_date DESC);

-- Trigger pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Appliquer le trigger aux tables
CREATE TRIGGER update_accounts_updated_at BEFORE UPDATE ON accounts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Politique de sécurité RLS (Row Level Security)
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre la lecture des comptes (pour l'instant, accès public)
CREATE POLICY "Permettre lecture des comptes" ON accounts
  FOR SELECT USING (true);

-- Politique pour permettre la lecture des transactions
CREATE POLICY "Permettre lecture des transactions" ON transactions
  FOR SELECT USING (true);

-- Insertion de données de test (optionnel)
INSERT INTO accounts (external_id, name, type, balance, currency, iban, bic) VALUES
  ('acc_001', 'Compte Courant Principal', 'checking', 2543.67, 'EUR', 'ES7921000813610123456789', 'CAIXESBBXXX'),
  ('acc_002', 'Compte Épargne', 'savings', 15678.90, 'EUR', 'ES7921000813610987654321', 'CAIXESBBXXX'),
  ('acc_003', 'Compte Partagé', 'shared', 4532.15, 'EUR', 'ES7921000813610111222333', 'CAIXESBBXXX')
ON CONFLICT (external_id) DO NOTHING;