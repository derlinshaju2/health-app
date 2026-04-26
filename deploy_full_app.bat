@echo off
echo ========================================
echo AI Health Monitoring App - Full Deployment
echo ========================================
echo.

echo Step 1: Installing Vercel CLI...
call npm install -g vercel
if %errorlevel% neq 0 (
    echo Failed to install Vercel CLI
    pause
    exit /b 1
)

echo.
echo Step 2: Deploying to Vercel...
echo.
echo IMPORTANT: You will need to set these environment variables:
echo   - MONGODB_URI (your MongoDB Atlas connection string)
echo   - JWT_SECRET (a secure random string, min 32 chars)
echo   - NODE_ENV=production
echo.
echo You can set them during deployment or in Vercel Dashboard later
echo.
pause

call vercel

if %errorlevel% neq 0 (
    echo Deployment failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo Deployment Successful!
echo ========================================
echo.
echo Your app is now live!
echo.
echo IMPORTANT: Set your environment variables in Vercel:
echo 1. Go to https://vercel.com/dashboard
echo 2. Select your project
echo 3. Go to Settings -^> Environment Variables
echo 4. Add these variables:
echo    - MONGODB_URI (your MongoDB connection string)
echo    - JWT_SECRET (generate at: https://www.uuidgenerator.net/api/version4)
echo    - NODE_ENV = production
echo.
echo After setting variables, redeploy with: vercel --prod
echo.
pause
