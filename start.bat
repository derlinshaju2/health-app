@echo off
echo ================================================
echo AI Health Monitoring Application - Startup Script
echo ================================================
echo.

echo Starting MongoDB...
start cmd /k "mongod"
timeout /t 3 > nul

echo Starting Backend API...
cd health-backend
start cmd /k "npm run dev"
cd ..
timeout /t 2 > nul

echo Starting ML Service...
cd health-backend/ml-service
start cmd /k "python app.py"
cd ..
timeout /t 2 > nul

echo Starting Flutter App...
cd health_app
start cmd /k "flutter run"
cd ..

echo.
echo ================================================
echo All services are starting up...
echo Backend API: http://localhost:5000
echo ML Service: http://localhost:8000
echo Flutter App: Starting...
echo ================================================
echo.
echo Press any key to exit this window (services will continue running)...
pause > nul