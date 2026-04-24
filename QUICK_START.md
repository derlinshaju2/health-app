# 🚀 Quick Start Guide - AI Health Monitoring Application

## Complete Setup Instructions

### Prerequisites Checklist
- [ ] Node.js (v18 or higher)
- [ ] Python (v3.8 or higher)
- [ ] MongoDB (v5.0 or higher)
- [ ] Flutter SDK (v3.0 or higher)
- [ ] Git
- [ ] Code Editor (VS Code, Android Studio, etc.)

### Option 1: Automatic Startup (Windows)

Run the provided startup script:
```bash
start.bat
```

This will automatically start:
- MongoDB database
- Backend API server
- ML microservice
- Flutter mobile application

### Option 2: Manual Startup

#### Step 1: Start MongoDB
```bash
mongod
```
MongoDB will run on port 27017

#### Step 2: Start Backend API
```bash
cd health-backend
npm install
npm run dev
```
Backend API will run on http://localhost:5000

#### Step 3: Start ML Service
```bash
cd health-backend/ml-service
pip install -r requirements.txt
python train_models.py  # Optional: train ML models
python app.py
```
ML Service will run on http://localhost:8000

#### Step 4: Start Flutter App
```bash
cd health_app
flutter pub get
flutter run
```

The mobile app will launch on your connected device or emulator

### Option 3: Docker Startup

If you have Docker installed:
```bash
docker-compose up
```

This will start all services in containers.

## First Time Setup

### 1. Backend Configuration
```bash
cd health-backend
cp .env.example .env
# Edit .env with your configuration if needed
```

### 2. Train ML Models (Optional but Recommended)
```bash
cd health-backend/ml-service
python train_models.py
```
This trains 4 disease prediction models with ~10,000 synthetic records.

### 3. Flutter Configuration
```bash
cd health_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:5000
```

## Testing the Application

### 1. Create User Account
- Open the Flutter app
- Click "Register"
- Enter email, password, and basic profile information
- Complete profile setup

### 2. Add Health Metrics
- From dashboard, click "Add Metrics"
- Enter blood pressure, blood sugar, cholesterol, weight
- Save the metrics

### 3. Generate AI Predictions
- Navigate to "AI Predictions"
- Click "Generate Prediction"
- View disease risk analysis

### 4. Test API Endpoints
Use Postman or curl to test:

```bash
# Register User
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Health Check
curl http://localhost:5000/health
```

## Troubleshooting

### MongoDB Issues
**Problem**: MongoDB won't start
**Solution**:
```bash
# Create data directory
mkdir -p C:/data/db
# Start MongoDB with explicit path
mongod --dbpath C:/data/db
```

### Backend API Issues
**Problem**: API won't connect to MongoDB
**Solution**: Check MONGODB_URI in `.env` file
```env
MONGODB_URI=mongodb://localhost:27017/healthdb
```

### ML Service Issues
**Problem**: ML service not responding
**Solution**: Check if Python dependencies are installed
```bash
pip install -r requirements.txt
```

### Flutter App Issues
**Problem**: App can't connect to API
**Solution**: Set API base URL explicitly
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```
(Use your computer's IP address instead of localhost for emulators)

### Port Conflicts
**Problem**: Port already in use
**Solution**: Change port in `.env` files
```env
# Backend
PORT=5001
# ML Service
ML_SERVICE_PORT=8001
```

## Development Workflow

### Making Changes to Backend
1. Edit files in `health-backend/src/`
2. Changes auto-reload with `npm run dev`
3. Test endpoints at http://localhost:5000

### Making Changes to ML Service
1. Edit files in `health-backend/ml-service/`
2. Restart Python service: `python app.py`
3. Test at http://localhost:8000

### Making Changes to Flutter App
1. Edit files in `health_app/lib/`
2. Use Hot Reload: Press `r` in terminal
3. Use Hot Restart: Press `R` in terminal

## Architecture Overview

### Services Communication
```
Flutter App (Mobile UI)
    ↓ HTTP requests
Express API (Port 5000)
    ↓ HTTP requests
Python ML Service (Port 8000)
    ↓
MongoDB (Port 27017)
```

### Key Files Location
- **Backend Logic**: `health-backend/src/controllers/`
- **Database Models**: `health-backend/src/models/`
- **API Routes**: `health-backend/src/routes/`
- **ML Models**: `health-backend/ml-service/models/`
- **Flutter UI**: `health_app/lib/features/`
- **State Management**: `health_app/lib/**/providers/`

## Production Deployment

### Backend Deployment
1. Update `.env` with production values
2. Set `NODE_ENV=production`
3. Deploy to AWS/GCP/Azure
4. Configure MongoDB Atlas
5. Deploy ML service separately

### Flutter App Deployment
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Support & Documentation

- **API Documentation**: Check `health-backend/README.md`
- **Flutter Documentation**: Check `health_app/README.md`
- **ML Models**: Check `health-backend/ml-service/README.md`
- **Issues**: Report on GitHub Issues

## Next Steps

1. ✅ Core features implemented
2. 🔄 Enhanced features (Diet, Yoga, Notifications) ready
3. 🚀 Advanced features (Chatbot, Social) planned

Start building your health journey today! 🏥💪