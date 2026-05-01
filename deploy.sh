#!/bin/bash

# Health App - Git Deployment Script
# This script commits and pushes changes to trigger automatic Vercel deployment

echo "🚀 Health App - Git Deployment"
echo "================================"

# Check if there are changes to deploy
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ No changes to deploy. Working directory is clean."
    exit 0
fi

# Show current status
echo "📋 Current Git Status:"
git status --short

# Ask for commit message
echo ""
echo "📝 Enter commit message (or press Enter for default):"
read -r commit_message

# Use default message if none provided
if [ -z "$commit_message" ]; then
    commit_message="Update health app - $(date +'%Y-%m-%d %H:%M:%S')"
fi

# Add all changes
echo ""
echo "➕ Adding changes to Git..."
git add .

# Commit changes
echo "✅ Committing changes..."
git commit -m "$commit_message"

# Push to GitHub
echo "🚀 Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Deployment initiated!"
echo "🌐 Your app will be available at: https://health-app-orpin-three.vercel.app"
echo "📊 Check deployment status at: https://vercel.com/dashboard"