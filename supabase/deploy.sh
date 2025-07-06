#!/bin/bash

# Script de déploiement pour les Edge Functions Supabase
# Usage: ./deploy.sh [local|prod]

MODE=${1:-local}

echo "🚀 Déploiement des Edge Functions Supabase en mode: $MODE"

if [ "$MODE" = "local" ]; then
    echo "📦 Démarrage de Supabase local..."
    supabase start
    
    echo "🔧 Déploiement des fonctions localement..."
    supabase functions serve &
    
    echo "✅ Fonctions disponibles sur:"
    echo "   - accounts-direct: http://localhost:54321/functions/v1/accounts-direct"
    echo "   - transactions: http://localhost:54321/functions/v1/transactions"
    echo "   - test-transactions: http://localhost:54321/functions/v1/test-transactions"
    echo "   - Supabase Studio: http://localhost:54323"
    
elif [ "$MODE" = "prod" ]; then
    echo "🔐 Vérification de la connexion Supabase..."
    if ! supabase projects list > /dev/null 2>&1; then
        echo "❌ Erreur: Vous devez vous connecter à Supabase d'abord:"
        echo "   supabase login"
        exit 1
    fi
    
    echo "📤 Déploiement en production..."
    
    # Déployer chaque fonction
    echo "📦 Déploiement de accounts-direct..."
    supabase functions deploy accounts-direct
    
    echo "📦 Déploiement de transactions..."
    supabase functions deploy transactions
    
    echo "📦 Déploiement de test-transactions..."
    supabase functions deploy test-transactions
    
    echo "🗄️ Application des migrations de base de données..."
    supabase db push
    
    echo "✅ Déploiement terminé!"
    echo "   Vérifiez vos fonctions dans le dashboard Supabase"
    
else
    echo "❌ Mode non reconnu. Utilisez 'local' ou 'prod'"
    echo "Usage: ./deploy.sh [local|prod]"
    exit 1
fi

echo "🎉 Déploiement terminé!"