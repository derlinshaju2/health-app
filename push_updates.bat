@echo off
echo ================================================
echo Push Updates to GitHub and Vercel
echo ================================================
echo.
echo Your updates ready to push:
echo 1. Enhanced User Profile Module
echo 2. Simplified Registration (name, email, password only)
echo 3. Vercel Deployment Configuration
echo.
echo Once pushed to GitHub, Vercel will auto-deploy!
echo.
pause

cd "C:\Users\derli\your-awesome-project"

echo.
echo Pushing to GitHub...
git push origin main

echo.
echo ================================================
echo Updates Pushed Successfully!
echo ================================================
echo.
echo Next Steps:
echo 1. Check GitHub: https://github.com/derlinshaju2/health-app
echo 2. Vercel will auto-deploy in 1-2 minutes
echo 3. Your updated app will be at: https://your-awesome-project.vercel.app
echo.
echo What's New:
echo - Simplified registration (only name, email, password)
echo - Enhanced profile management with edit functionality
echo - Profile picture upload system
echo - Auto BMI calculation with color-coded categories
echo - Vercel deployment configuration
echo.
pause