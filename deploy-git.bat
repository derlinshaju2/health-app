@echo off
REM Health App - Git Deployment Script for Windows
REM This script commits and pushes changes to trigger automatic Vercel deployment

echo ============================================
echo 🚀 Health App - Git Deployment
echo ============================================
echo.

REM Check if there are changes to deploy
git status --porcelain >nul
if %errorlevel% neq 0 (
    echo ✅ No changes to deploy. Working directory is clean.
    pause
    exit /b 0
)

REM Show current status
echo 📋 Current Git Status:
git status --short
echo.

REM Ask for commit message
echo 📝 Enter commit message (or press Enter for default):
set /p commit_message=""

REM Use default message if none provided
if "%commit_message%"=="" (
    set commit_message=Update health app - %date% %time%
)

REM Add all changes
echo.
echo ➕ Adding changes to Git...
git add .

REM Commit changes
echo ✅ Committing changes...
git commit -m "%commit_message%"

REM Push to GitHub
echo 🚀 Pushing to GitHub...
git push origin main

echo.
echo ✅ Deployment initiated!
echo 🌐 Your app will be available at: https://health-app-orpin-three.vercel.app
echo 📊 Check deployment status at: https://vercel.com/dashboard
echo.
pause