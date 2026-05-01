@echo off
echo ========================================
echo DEPLOY HEALTH APP TO NETLIFY
echo ========================================
echo.
echo Your improved health app is ready to deploy!
echo.
echo Deployment Options:
echo.
echo OPTION 1 - Automatic Deployment (RECOMMENDED):
echo   Your site is already connected to GitHub
echo   Netlify should auto-deploy when you push changes
echo   Check: https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/deploys
echo.
echo OPTION 2 - Manual Drag & Drop:
echo   1. Go to https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/overview
echo   2. Click "Drag and drop your site output folder"
echo   3. Select the "public" folder
echo   4. Wait for deployment to complete
echo.
echo OPTION 3 - Netlify CLI (if authenticated):
echo   Run: netlify deploy --prod --dir=public
echo.
echo ========================================
echo YOUR APP WILL BE LIVE AT:
echo https://velvety-clafoutis-9bb7e2.netlify.app
echo ========================================
echo.
echo Opening Netlify deployment pages...
timeout /t 2 >nul
start "" "https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/deploys"
start "" "https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/overview"
echo.
echo Netlify pages opened! Monitor your deployment there.
echo.
pause
