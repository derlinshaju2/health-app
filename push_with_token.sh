#!/bin/bash
# GitHub Push with Personal Access Token
# Usage: Replace YOUR_GITHUB_TOKEN below with your actual token, then run this script

GITHUB_TOKEN="YOUR_GITHUB_TOKEN"
REPO_URL="https://${GITHUB_TOKEN}@github.com/derlinshaju2/health-app.git"

echo "Pushing to GitHub with Personal Access Token..."
git push "${REPO_URL}" main

echo "Push completed!"