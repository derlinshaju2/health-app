@echo off
echo ========================================
echo Deploy AI Health App to Vercel
echo ========================================
echo.

echo Step 1: Installing Vercel CLI...
call npm install -g vercel

echo.
echo Step 2: Login to Vercel...
echo A browser window will open for authentication
call vercel login

echo.
echo Step 3: Deploying your app...
echo Follow the prompts to complete deployment
call vercel

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo Your app is now live!
echo You can access it at the URL shown above.
echo.
echo IMPORTANT: Set these environment variables in Vercel Dashboard:
echo 1. Go to https://vercel.com/dashboard
echo 2. Select your project
echo 3. Settings -^> Environment Variables
echo 4. Add:
echo    - MONGODB_URI (your MongoDB connection string)
echo    - JWT_SECRET (generate at: https://www.uuidgenerator.net/api/version4)
echo    - NODE_ENV = production
echo.
pause
