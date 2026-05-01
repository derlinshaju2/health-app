# Auto-Deploy shadcn/ui Health App to Netlify
Write-Host "========================================" -ForegroundColor Green
Write-Host "AUTO-DEPLOYING SHADCN/UI HEALTH APP" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Code is already on GitHub!" -ForegroundColor Green
Write-Host "   Repository: https://github.com/derlinshaju2/health-app" -ForegroundColor Cyan
Write-Host ""

Write-Host "🚀 Opening Netlify for GitHub integration..." -ForegroundColor Yellow
Write-Host ""

# Open Netlify deployment page
Start-Process "https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/deploys"

Start-Sleep -Seconds 2

Write-Host "📋 NEXT STEPS (Just 3 clicks):" -ForegroundColor Magenta
Write-Host ""
Write-Host "1. On Netlify page that opened:" -ForegroundColor White
Write-Host "   - Click 'Link to GitHub' or 'Connect to GitHub'" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. Select 'health-app' repository" -ForegroundColor White
Write-Host "   - Branch: master" -ForegroundColor Cyan
Write-Host "   - Build command: npm run build" -ForegroundColor Cyan
Write-Host "   - Publish directory: .next" -ForegroundColor Cyan
Write-Host ""

Write-Host "3. Click 'Deploy Site'" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "YOUR APP WILL BE LIVE AT:" -ForegroundColor Green
Write-Host "https://velvety-clafoutis-9bb7e2.netlify.app" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to open Netlify deployment page..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open Netlify deployment page again
Start-Process "https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/deploys"

Write-Host ""
Write-Host "Netlify deployment page opened! Follow the 3 steps above." -ForegroundColor Green
Write-Host ""
