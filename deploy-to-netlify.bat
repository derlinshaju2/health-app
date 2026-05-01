@echo off
echo ========================================
echo Deploying to Netlify...
echo ========================================
echo.
echo Files being deployed:
echo - analytics.html
echo - diet-tracking.html
echo - disease-prediction.html
echo - bmi-calculator.html
echo - yoga-tracker.html
echo.
echo Please follow these steps:
echo.
echo 1. Open File Explorer to: c:\Users\derli\your-awesome-project\
echo 2. Select the 5 HTML files listed above
echo 3. Go to https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/overview
echo 4. Drag and drop the files onto the Netlify page
echo.
echo Opening your file location and Netlify dashboard...
echo.

timeout /t 2

start "" "c:\Users\derli\your-awesome-project\"
start "" "https://app.netlify.com/sites/velvety-clafoutis-9bb7e2/overview"

echo.
echo ========================================
echo Both File Explorer and Netlify are now open
echo ========================================
echo.
echo Drag the 5 HTML files from File Explorer to Netlify
echo.
pause
