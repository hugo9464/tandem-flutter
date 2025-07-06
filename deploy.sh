#!/bin/bash

# Script de déploiement local vers Netlify
set -e

echo "🚀 Déploiement Tandem PWA vers Netlify"
echo "======================================"

# Vérification des prérequis
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou pas dans le PATH"
    exit 1
fi

if ! command -v netlify &> /dev/null; then
    echo "❌ Netlify CLI n'est pas installé"
    echo "💡 Installez-le avec: npm install -g netlify-cli"
    exit 1
fi

echo "✅ Prérequis validés"

# Build Flutter web
echo ""
echo "🏗️ Build de l'application Flutter web..."
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit

# Vérification du build
if [ ! -d "build/web" ]; then
    echo "❌ Le build a échoué - dossier build/web introuvable"
    exit 1
fi

echo "✅ Build Flutter terminé avec succès"

# Affichage des fichiers générés
echo ""
echo "📦 Fichiers générés:"
ls -la build/web/

# Déploiement vers Netlify
echo ""
echo "🌐 Déploiement vers Netlify..."

# Vous pouvez choisir entre:
# 1. Déploiement de preview: netlify deploy
# 2. Déploiement en production: netlify deploy --prod

read -p "Déployer en production? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Déploiement en PRODUCTION..."
    netlify deploy --prod --dir=build/web
else
    echo "🔍 Déploiement de PREVIEW..."
    netlify deploy --dir=build/web
fi

echo ""
echo "✅ Déploiement terminé!"
echo "🌍 Votre PWA Tandem est maintenant en ligne"