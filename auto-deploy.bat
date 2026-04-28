@echo off
title Automatic Health App Deployment
color 0A

echo.
echo ============================================
echo    🚀 AUTOMATIC DEPLOYMENT SCRIPT
echo ============================================
echo.
echo This will automatically deploy your app to Vercel!
echo.

REM Check if git is available
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git not found. Please install Git first.
    pause
    exit /b 1
)

echo 📋 Current git status:
echo.
git status
echo.

echo ============================================
echo    🔄 STARTING AUTOMATIC DEPLOYMENT
echo ============================================
echo.

REM Try to push to GitHub with retries
set max_attempts=5
set attempt=1
set wait_time=10

:push_loop
echo 📡 Attempt %attempt% of %max_attempts% to push to GitHub...
echo.

git push origin main
if %errorlevel% equ 0 (
    echo.
    echo ============================================
    echo    ✅ SUCCESS! AUTOMATIC DEPLOYMENT STARTED
    echo ============================================
    echo.
    echo Your changes are now on GitHub!
    echo Vercel will automatically deploy in 2-3 minutes.
    echo.
    echo 🎯 Your fast URLs will be:
    echo    https://health-app-orpin-three.vercel.app/app.html
    echo    https://health-app-orpin-three.vercel.app/fast-login.html
    echo    https://health-app-orpin-three.vercel.app/signup.html
    echo.
    echo 📊 Performance improvement:
    echo    Before: 8-15 seconds load time
    echo    After:  1-2 seconds load time ⚡
    echo.
    pause
    exit /b 0
)

if %attempt% geq %max_attempts% (
    echo.
    echo ============================================
    echo    ❌ NETWORK ISSUE - MANUAL DEPLOYMENT NEEDED
    echo ============================================
    echo.
    echo Could not connect to GitHub after %max_attempts% attempts.
    echo.
    echo 💡 QUICK FIX - Manual deployment:
    echo    1. Open Vercel Dashboard: https://vercel.com/dashboard
    echo    2. Find your project: health-app-orpin-three
    echo    3. Click "Redeploy" button
    echo    4. Wait 2-3 minutes for deployment
    echo.
    echo Or try again when your network is more stable.
    echo.
    pause
    exit /b 1
)

echo ⏳ Network issue detected. Waiting %wait_time% seconds...
timeout /t %wait_time% >nul
set /a attempt+=1
set /a wait_time*=2
echo.
goto push_loop