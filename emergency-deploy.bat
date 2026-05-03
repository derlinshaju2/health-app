@echo off
ECHO ========================================
ECHO Emergency Chart Fix Deployment
ECHO ========================================
ECHO.

ECHO This script will deploy the canvas fix when you're ready
ECHO The fix prevents the "Canvas is already in use" error
ECHO.

ECHO Step 1: Push to GitHub (when network is stable)...
git push origin main
IF %ERRORLEVEL% NEQ 0 (
    ECHO ❌ GitHub push failed - try again when network is stable
    ECHO.
    ECHO Alternative: Manual deployment instructions:
    ECHO 1. Go to https://github.com/derlinshaju2/health-app
    ECHO 2. Upload the files manually or use GitHub web interface
    ECHO 3. Vercel will auto-deploy from GitHub
    PAUSE
    EXIT /B 1
)

ECHO ✅ GitHub push successful!
ECHO.
ECHO Vercel will automatically deploy from GitHub.
ECHO Your charts fix will be live in 1-2 minutes.
ECHO.

PAUSE