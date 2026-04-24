# 🏥 AI-Driven Health Monitoring Application

A comprehensive full-stack mobile health monitoring application with AI-powered disease prediction, personalized wellness recommendations, and yoga tracking.

## 🌟 Features

### Core Features
- 🔐 **Secure Authentication** - JWT-based user authentication
- 📊 **Health Dashboard** - Real-time health metrics overview
- 🩺 **Health Metrics Tracking** - Blood pressure, blood sugar, cholesterol, BMI
- 🤖 **AI Disease Prediction** - ML-powered risk assessment for:
  - Hypertension
  - Diabetes
  - Heart Disease
  - Obesity-related conditions
- 🥗 **Personalized Diet Plans** - Meal recommendations based on health profile
- 🧘 **Yoga & Fitness Tracking** - Workout sessions, pose library, progress analytics
- 📈 **Health Analytics** - Charts, trends, and insights
- 🔔 **Smart Notifications** - Reminders, alerts, and scheduling

## 🏗️ Architecture

### Technology Stack

**Frontend:**
- Flutter (Dart) with Provider state management
- Material Design 3 with custom health themes
- Responsive mobile-first design
- Dark mode support

**Backend:**
- Node.js + Express.js REST API
- MongoDB with Mongoose ODM
- JWT authentication
- WebSocket for real-time notifications

**ML Service:**
- Python Flask microservice
- Scikit-learn for ML models
- Real disease prediction algorithms
- Model training and inference

### System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Flutter App    │◄──►│  Express API    │◄──►│   MongoDB       │
│  (Mobile UI)    │    │  (REST/WS)      │    │   (Database)    │
└─────────────────┘    └────────┬────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │  Python ML      │
                       │  Microservice   │
                       └─────────────────┘
```

## 🚀 Getting Started

### Prerequisites

- Node.js >= 18.0.0
- Python >= 3.8
- MongoDB >= 5.0
- Flutter SDK >= 3.0.0
- Docker (optional)

### Quick Start

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd your-awesome-project
```

#### 2. Backend Setup

```bash
cd health-backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your configuration

# Start MongoDB (or use MongoDB Atlas)
mongod

# Start backend server
npm run dev
```

Backend will run on `http://localhost:5000`

#### 3. ML Service Setup

```bash
cd health-backend/ml-service

# Install Python dependencies
pip install -r requirements.txt

# Train ML models (optional - fallback available)
python train_models.py

# Start ML service
python app.py
```

ML service will run on `http://localhost:8000`

#### 4. Flutter App Setup

```bash
cd health_app

# Install dependencies
flutter pub get

# Run the app
flutter run --dart-define=API_BASE_URL=http://localhost:5000
```

#### 5. Docker Setup (Optional)

```bash
# Start all services with Docker Compose
docker-compose up

# Stop services
docker-compose down
```

## 📁 Project Structure

```
your-awesome-project/
├── health-backend/           # Node.js backend API
│   ├── src/
│   │   ├── config/          # Configuration files
│   │   ├── controllers/     # Request handlers
│   │   ├── models/          # Mongoose models
│   │   ├── routes/          # API routes
│   │   ├── middleware/      # Express middleware
│   │   ├── services/        # Business logic
│   │   ├── utils/           # Utility functions
│   │   └── app.js           # Express app setup
│   ├── ml-service/          # Python ML microservice
│   │   ├── models/          # Trained ML models
│   │   ├── train_models.py  # Model training script
│   │   ├── app.py           # Flask API
│   │   └── requirements.txt # Python dependencies
│   ├── tests/               # Backend tests
│   ├── package.json
│   └── README.md
├── health_app/              # Flutter mobile app
│   ├── lib/
│   │   ├── core/            # Core functionality
│   │   ├── features/        # Feature modules
│   │   └── main.dart        # App entry point
│   ├── pubspec.yaml
│   └── README.md
├── docker-compose.yml       # Docker configuration
└── README.md                # This file
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get user profile
- `PUT /api/auth/profile` - Update profile

### Health Metrics
- `POST /api/health/metrics` - Save health metrics
- `GET /api/health/dashboard` - Get dashboard data
- `GET /api/health/metrics/latest` - Get latest metrics
- `GET /api/health/metrics/history/:period` - Get metrics history

### AI Predictions
- `POST /api/predictions/generate` - Generate predictions
- `GET /api/predictions/latest` - Get latest prediction
- `GET /api/predictions/trends` - Get risk trends

### Diet & Nutrition
- `GET /api/diet/recommendations` - Get diet recommendations
- `POST /api/diet/food-log` - Log food intake
- `GET /api/diet/meal-plan/:date` - Get meal plan

### Yoga & Fitness
- `POST /api/yoga/session` - Save yoga session
- `GET /api/yoga/sessions/:period` - Get session history
- `GET /api/yoga/progress/:userId` - Get progress stats

## 🤖 Machine Learning Models

### Disease Prediction Models

**1. Hypertension Risk Prediction**
- Algorithm: Random Forest Classifier
- Accuracy: >85%
- Features: Age, BMI, Blood Pressure, Cholesterol, Activity Level

**2. Diabetes Risk Prediction**
- Algorithm: Logistic Regression
- Accuracy: >80%
- Features: Blood Sugar, BMI, Age, Family History, Lifestyle

**3. Heart Disease Risk Prediction**
- Algorithm: Decision Tree
- Accuracy: >75%
- Features: Age, BMI, Blood Pressure, Cholesterol, Smoking

**4. Obesity-Related Conditions**
- Algorithm: Support Vector Machine
- Accuracy: >70%
- Features: BMI, Activity Level, Lifestyle Factors

### Training ML Models

```bash
cd health-backend/ml-service
python train_models.py
```

This generates synthetic health data and trains all models with cross-validation.

## 🔒 Security Features

- JWT token authentication
- Password hashing with bcrypt
- Rate limiting on API endpoints
- Input validation and sanitization
- CORS configuration
- Secure token storage (Flutter)
- HTTPS support in production

## 📱 Mobile App Features

### Screens
1. **Splash Screen** - App initialization
2. **Login/Register** - User authentication
3. **Home Dashboard** - Health overview
4. **Health Metrics Input** - Data entry forms
5. **Prediction Results** - AI risk analysis
6. **Diet Recommendations** - Meal plans
7. **Yoga Tracker** - Workout sessions
8. **Progress Analytics** - Charts and trends

### UI/UX
- Material Design 3
- Light and dark themes
- Responsive layouts
- Smooth animations
- Offline support (planned)
- Biometric authentication (planned)

## 🧪 Testing

### Backend Tests

```bash
cd health-backend
npm test
```

### ML Service Tests

```bash
cd health-backend/ml-service
pytest
```

### Flutter Tests

```bash
cd health_app
flutter test
```

## 📊 Database Schema

### Users Collection
- Email, password (hashed)
- Profile (name, age, gender, height, weight, BMI)
- Medical history, existing conditions
- Activity level

### Health Metrics Collection
- User ID, date
- Blood pressure, blood sugar, cholesterol
- Weight, temperature, heart rate

### Disease Predictions Collection
- User ID, date
- Predictions (disease, risk score, likelihood)
- Input metrics, model version

### Diet Plans Collection
- User ID, date
- Daily calorie target
- Meals with nutritional breakdown
- Water intake tracking

### Yoga Sessions Collection
- User ID, date
- Routine type, duration, poses
- Calories burned, completion status

## 🔧 Configuration

### Environment Variables

**Backend (.env):**
```env
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/healthdb
JWT_SECRET=your-secret-key
ML_SERVICE_URL=http://localhost:8000
```

**Flutter:**
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:5000
```

## 🚀 Deployment

### Backend Deployment

**AWS Elastic Beanstalk:**
```bash
eb create health-backend-env
```

**Google Cloud Run:**
```bash
gcloud run deploy health-backend --image gcr.io/PROJECT_ID/health-backend
```

**Docker:**
```bash
docker build -t health-backend ./health-backend
docker run -p 5000:5000 health-backend
```

### Flutter App Deployment

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📈 Monitoring & Analytics

- Application performance monitoring
- ML model accuracy tracking
- User engagement metrics
- Health data trends
- API usage analytics

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- Your Name - Initial work

## 🙏 Acknowledgments

- Flutter team for amazing framework
- Scikit-learn for ML tools
- Medical community for health guidelines

## 📞 Support

For support, email support@healthmonitor.com or open an issue on GitHub.

## 🗺️ Roadmap

### Phase 1: Core Features ✅
- Authentication
- Health Metrics
- AI Predictions
- Basic Dashboard

### Phase 2: Enhanced Features (In Progress)
- Diet & Nutrition Module
- Yoga & Fitness Tracking
- Advanced Analytics
- Notification System

### Phase 3: Advanced Features (Planned)
- AI Health Chatbot
- Wearable Integration
- Social Features
- Multi-language Support

---

**Built with ❤️ for better health monitoring**