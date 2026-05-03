# PowerShell Deployment Script for Analytics Charts Fix
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploying Analytics Charts Fix to Vercel" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git not found. Please install Git first." -ForegroundColor Red
    exit 1
}

# Check if vercel CLI is available
if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Vercel CLI not found. Installing..." -ForegroundColor Yellow
    npm i -g vercel
}

Write-Host "Step 1: Pushing changes to GitHub..." -ForegroundColor Green
try {
    git push origin main
    Write-Host "✅ GitHub push successful" -ForegroundColor Green
} catch {
    Write-Host "❌ GitHub push failed: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 2: Deploying to Vercel production..." -ForegroundColor Green
try {
    vercel --prod --yes
    Write-Host "✅ Vercel deployment successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Vercel deployment failed: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your analytics page with fixed charts is now live at:" -ForegroundColor White
Write-Host "https://health-app-orpin-three.vercel.app/analytics.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "Fixed charts:" -ForegroundColor White
Write-Host "✅ Health Score Chart" -ForegroundColor Green
Write-Host "✅ Weight Trends Chart" -ForegroundColor Green
Write-Host "✅ Calorie Trends Chart" -ForegroundColor Green
Write-Host "✅ Sleep Trends Chart" -ForegroundColor Green
Write-Host "✅ Workout Frequency Chart" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit"