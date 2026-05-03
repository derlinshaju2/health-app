@echo off
ECHO ========================================
ECHO Deploying Analytics Charts Fix to Vercel
ECHO ========================================
ECHO.

ECHO Step 1: Pushing changes to GitHub...
git push origin main
IF %ERRORLEVEL% NEQ 0 (
    ECHO ❌ GitHub push failed
    PAUSE
    EXIT /B 1
)
ECHO ✅ GitHub push successful
ECHO.

ECHO Step 2: Deploying to Vercel production...
vercel --prod --yes
IF %ERRORLEVEL% NEQ 0 (
    ECHO ❌ Vercel deployment failed
    PAUSE
    EXIT /B 1
)
ECHO ✅ Vercel deployment successful
ECHO.

ECHO ========================================
ECHO 🎉 Deployment Complete!
ECHO ========================================
ECHO.
ECHO Your analytics page with fixed charts is now live at:
ECHO https://health-app-orpin-three.vercel.app/analytics.html
ECHO.
ECHO Fixed charts:
ECHO ✅ Health Score Chart
ECHO ✅ Weight Trends Chart
ECHO ✅ Calorie Trends Chart
ECHO ✅ Sleep Trends Chart
ECHO ✅ Workout Frequency Chart
ECHO.

PAUSE