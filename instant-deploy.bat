@echo off
echo ========================================
echo DEPLOYING SHADCN/UI HEALTH APP TO NETLIFY
echo ========================================
echo.

echo [1/3] Opening File Explorer to health-app folder...
timeout /t 2 >nul
start explorer "c:\Users\derli\your-awesome-project\health-app"

echo [2/3] Opening Netlify dashboard...
timeout /t 2 >nul
start "" "https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/overview"

echo [3/3] Deployment Instructions...
echo.
echo ========================================
echo DRAG & DROP DEPLOYMENT:
echo ========================================
echo.
echo STEP 1: In File Explorer, click ONCE on the "health-app" folder
echo.
echo STEP 2: Drag the "health-app" folder onto the Netlify page
echo.
echo STEP 3: Wait 2-3 minutes for deployment to complete
echo.
echo STEP 4: Visit: https://velvety-clafoutis-9bb7e2.netlify.app
echo.
echo ========================================
echo YOUR SHADCN/UI HEALTH APP FEATURES:
echo ========================================
echo.
echo ✓ Next.js 14 + TypeScript
echo ✓ shadcn/ui components throughout
echo ✓ All 6 pages: Dashboard, BMI, Disease, Diet, Analytics, Profile
echo ✓ Responsive design (mobile + desktop)
echo ✓ Your color scheme: #6366f1, #8b5cf6
echo ✓ Production-ready build
echo.
echo ========================================
echo.

echo Both File Explorer and Netlify are now open!
echo Drag the health-app folder to Netlify to deploy.
echo.
pause
