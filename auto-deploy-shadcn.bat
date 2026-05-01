@echo off
echo ========================================
echo Auto-Deploying shadcn/ui Health App to Netlify
echo ========================================
echo.

echo Step 1: Preparing deployment files...
echo.
echo The health-app folder contains your complete Next.js + shadcn/ui application
echo.

echo Step 2: Opening Netlify deployment options...
echo.
echo Choose ONE of these deployment methods:
echo.
echo OPTION 1 - Drag & Drop (EASIEST):
echo   1. Go to https://app.netlify.com/
echo   2. Find your site: velvety-clafoutis-9bb7e2
echo   3. Drag the entire health-app folder onto Netlify
echo   4. Wait 2-3 minutes for deployment
echo.
echo OPTION 2 - Manual Deploy:
echo   1. Go to https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/overview
echo   2. Click "Deploy site" or "Change production branch"
echo   3. Select the health-app folder
echo   4. Deploy
echo.
echo OPTION 3 - GitHub Auto-Deploy:
echo   1. Create a new GitHub repository
echo   2. Push health-app folder to GitHub
echo   3. In Netlify, click "New site from Git"
echo   4. Select your repository
echo   5. Auto-deploy on every push
echo.

echo Opening your folders and Netlify dashboard...
echo.

start "" "c:\Users\derli\your-awesome-project\health-app"
start "" "https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/overview"

echo.
echo ========================================
echo Deployment files ready!
echo ========================================
echo.
echo Your shadcn/ui health app is ready to deploy!
echo.
pause
