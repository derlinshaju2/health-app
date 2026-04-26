@echo off
echo Pushing to GitHub with your Personal Access Token...
echo.

REM Replace YOUR_GITHUB_TOKEN below with your actual token
set GITHUB_TOKEN=YOUR_GITHUB_TOKEN

cd "C:\Users\derli\your-awesome-project"
git remote set-url origin https://%GITHUB_TOKEN%@github.com/derlinshaju2/health-app.git
git push origin main
git remote set-url origin https://github.com/derlinshaju2/health-app.git

echo.
echo Push completed! Token cleared from remote URL.
pause