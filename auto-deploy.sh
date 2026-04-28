#!/bin/bash

echo "🚀 AUTOMATIC DEPLOYMENT SCRIPT"
echo "================================"
echo ""

# Function to retry git push with backoff
retry_push() {
    local max_attempts=5
    local attempt=1
    local wait_time=10

    while [ $attempt -le $max_attempts ]; do
        echo "📡 Attempt $attempt of $max_attempts to push to GitHub..."

        if git push origin main; then
            echo "✅ SUCCESS! Changes pushed to GitHub"
            echo "🔄 Vercel will automatically deploy in 2-3 minutes"
            return 0
        fi

        if [ $attempt -lt $max_attempts ]; then
            echo "⏳ Network issue. Waiting ${wait_time}s before retry..."
            sleep $wait_time
            wait_time=$((wait_time * 2))  # Exponential backoff
        fi

        attempt=$((attempt + 1))
    done

    echo "❌ Failed to push after $max_attempts attempts"
    echo "💡 Manual deployment needed:"
    echo "   1. Go to https://vercel.com/dashboard"
    echo "   2. Find your project and click 'Redeploy'"
    return 1
}

# Check git status
echo "📋 Checking git status..."
git status

echo ""
echo "🔄 Pushing changes to trigger automatic Vercel deployment..."
echo ""

retry_push

echo ""
echo "🎯 Deployment URLs:"
echo "   Landing: https://health-app-orpin-three.vercel.app/app.html"
echo "   Login:   https://health-app-orpin-three.vercel.app/fast-login.html"
echo "   Signup:  https://health-app-orpin-three.vercel.app/signup.html"
echo ""