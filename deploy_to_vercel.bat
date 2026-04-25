@echo off
echo ================================================
echo Deploy Health App to Vercel
echo ================================================
echo.
echo This will deploy your health app to Vercel
echo Make sure you have:
echo 1. Vercel account (https://vercel.com)
echo 2. MongoDB Atlas connection string
echo 3. GitHub repository pushed
echo.
pause

cd "C:\Users\derli\your-awesome-project"

echo.
echo Step 1: Login to Vercel...
echo (A browser window will open for authentication)
vercel login

echo.
echo Step 2: Deploy to Vercel...
echo (This may take a few minutes)
vercel --prod

echo.
echo ================================================
echo Deployment Complete!
echo ================================================
echo.
echo Your health app is now live on Vercel!
echo Check your Vercel dashboard for the deployment URL.
echo.
echo Next Steps:
echo 1. Get your Vercel URL from the dashboard
echo 2. Update Flutter app with production URL
echo 3. Test all features
echo.
pause