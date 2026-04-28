@echo off
echo ============================================
echo    FAST DEPLOYMENT SCRIPT
echo ============================================
echo.
echo This script will help you deploy quickly!
echo.
echo PRESS ANY KEY TO START DEPLOYMENT...
pause > nul

echo.
echo Checking Vercel connection...
timeout /t 2 > nul

echo.
echo Opening Vercel Dashboard...
start https://vercel.com/dashboard

echo.
echo ============================================
echo    DEPLOYMENT INSTRUCTIONS:
echo ============================================
echo.
echo 1. Find your project: health-app-orpin-three
echo 2. Click the "Redeploy" button (top right)
echo 3. Wait 2-3 minutes for "Ready" status
echo.
echo Your fast URLs will be:
echo - https://health-app-orpin-three.vercel.app/app.html
echo - https://health-app-orpin-three.vercel.app/fast-login.html
echo.
echo ============================================
echo.
echo Press any key to open your project dashboard...
pause > nul

start https://vercel.com/derlin-shajus-projects/your-awesome-project

echo.
echo ============================================
echo    DEPLOYMENT IN PROGRESS
echo ============================================
echo.
echo Your files are ready locally:
echo - fast-login.html (Fast login page)
echo - signup.html (Quick signup page)
echo - app.html (Landing page)
echo - index.html (Smart index with auth check)
echo.
echo Just click "Redeploy" in Vercel dashboard!
echo.
echo ============================================
echo.
pause