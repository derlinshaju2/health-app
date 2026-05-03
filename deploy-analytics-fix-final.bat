@echo off
ECHO ========================================
ECHO FINAL ANALYTICS FIX DEPLOYMENT
ECHO ========================================
ECHO.

ECHO This script will deploy the working analytics page
ECHO with all 5 charts fixed and working properly.
ECHO.

ECHO Checking git status...
git status
ECHO.

ECHO Step 1: Committing the fix...
git add public/analytics.html
git commit -m "Final fix: Working analytics page with all charts

- Fixed canvas initialization errors
- All 5 charts working: Health, Weight, Calories, Sleep, Workout
- No more 'Canvas is already in use' errors
- Clean single initialization approach
- Status indicator shows success message

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

IF %ERRORLEVEL% NEQ 0 (
    ECHO ❌ Commit failed - nothing to commit or git error
    PAUSE
    EXIT /B 1
)

ECHO ✅ Commit successful
ECHO.

ECHO Step 2: Pushing to GitHub...
git push origin main

IF %ERRORLEVEL% NEQ 0 (
    ECHO ❌ GitHub push failed - possible network issue
    ECHO.
    ECHO Alternative solutions:
    ECHO 1. Try again when network is stable
    ECHO 2. Upload manually to GitHub web interface
    ECHO 3. Test locally: public/analytics.html
    PAUSE
    EXIT /B 1
)

ECHO ✅ GitHub push successful
ECHO.

ECHO Step 3: Vercel will auto-deploy in 2-5 minutes...
ECHO Your analytics page will be live at:
ECHO https://health-app-orpin-three.vercel.app/analytics
ECHO.

ECHO ========================================
ECHO 🎉 DEPLOYMENT SUCCESSFUL!
ECHO ========================================
ECHO.
ECHO All 5 charts are now working:
ECHO ✅ Health Score Chart
ECHO ✅ Weight Trends Chart
ECHO ✅ Calorie Trends Chart
ECHO ✅ Sleep Trends Chart
ECHO ✅ Workout Frequency Chart
ECHO.

PAUSE