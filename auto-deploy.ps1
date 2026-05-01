# Auto-deployment script for Netlify
Write-Host "Preparing deployment files..." -ForegroundColor Green

$files = @(
    "analytics.html",
    "diet-tracking.html",
    "disease-prediction.html",
    "bmi-calculator.html",
    "yoga-tracker.html"
)

$sourcePath = "c:\Users\derli\your-awesome-project"
$deployPath = "$sourcePath\netlify-deploy"

# Create deployment folder
New-Item -ItemType Directory -Force -Path $deployPath

# Copy files to deployment folder
foreach ($file in $files) {
    Copy-Item "$sourcePath\$file" -Destination "$deployPath\$file" -Force
    Write-Host "Copied: $file" -ForegroundColor Yellow
}

Write-Host "`nFiles ready for deployment!" -ForegroundColor Green
Write-Host "Deployment folder: $deployPath" -ForegroundColor Cyan
Write-Host "`nOpening File Explorer and Netlify..." -ForegroundColor Yellow

Start-Process "explorer.exe" -ArgumentList $deployPath
Start-Sleep -Seconds 2
Start-Process "https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/overview"

Write-Host "`nDrag all files from the open folder to Netlify!" -ForegroundColor Green
