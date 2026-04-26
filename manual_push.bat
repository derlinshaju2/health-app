@echo off
echo GitHub Push - Manual Authentication
echo ===================================
echo.
echo When prompted:
echo 1. Enter your GitHub username
echo 2. Enter your GitHub Personal Access Token (NOT your password)
echo.
echo Get token from: https://github.com/settings/tokens
echo.
pause

cd "C:\Users\derli\your-awesome-project"
git push origin main

pause