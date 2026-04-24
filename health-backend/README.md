# AI-Driven Health Monitoring Backend

Comprehensive backend API for AI-driven health monitoring application with disease prediction, diet recommendations, and fitness tracking.

## Features

- 🔐 **Secure Authentication** - JWT-based user authentication
- 📊 **Health Metrics Tracking** - Blood pressure, blood sugar, cholesterol, etc.
- 🤖 **AI Disease Prediction** - ML-powered risk assessment for hypertension, diabetes, heart disease, and obesity-related conditions
- 🥗 **Diet & Nutrition** - Meal planning, food tracking, calorie counting
- 🧘 **Yoga & Fitness** - Workout tracking, pose library, progress analytics
- 🔔 **Notifications** - Reminders, alerts, scheduling
- 📈 **Analytics & Trends** - Health metrics visualization and trend analysis

## Tech Stack

- **Node.js** + **Express.js** - REST API framework
- **MongoDB** + **Mongoose** - Database and ODM
- **JWT** - Authentication tokens
- **Python** + **Flask** - ML microservice
- **Scikit-learn** - ML models for disease prediction

## Getting Started

### Prerequisites

- Node.js >= 18.0.0
- MongoDB >= 5.0
- Python >= 3.8
- pip or pip3

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd health-backend
```

2. **Install Node.js dependencies**
```bash
npm install
```

3. **Install Python ML service dependencies**
```bash
cd ml-service
pip install -r requirements.txt
```

4. **Configure environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

5. **Start MongoDB**
```bash
# Using MongoDB locally
mongod

# Or use MongoDB Atlas connection string in .env
```

6. **Train ML models** (optional - will use fallback if skipped)
```bash
cd ml-service
python train_models.py
```

7. **Start the backend server**
```bash
npm run dev
```

8. **Start the ML service** (in a new terminal)
```bash
cd ml-service
python app.py
```

The API will be available at `http://localhost:5000`
The ML service will be available at `http://localhost:8000`

## API Documentation

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "profile": {
    "name": "John Doe",
    "age": 35,
    "gender": "male",
    "height": 175,
    "weight": 70,
    "activityLevel": "moderate"
  }
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Get Profile
```http
GET /api/auth/me
Authorization: Bearer <token>
```

### Health Metrics Endpoints

#### Create/Update Health Metrics
```http
POST /api/health/metrics
Authorization: Bearer <token>
Content-Type: application/json

{
  "date": "2024-01-15",
  "metrics": {
    "bloodPressure": {
      "systolic": 120,
      "diastolic": 80
    },
    "bloodSugar": 95,
    "cholesterol": {
      "total": 200,
      "ldl": 100,
      "hdl": 50
    },
    "weight": 70
  },
  "notes": "Feeling good today"
}
```

#### Get Health Dashboard
```http
GET /api/health/dashboard
Authorization: Bearer <token>
```

#### Get Metrics History
```http
GET /api/health/metrics/history/week
Authorization: Bearer <token>
```

### Disease Prediction Endpoints

#### Generate Predictions
```http
POST /api/predictions/generate
Authorization: Bearer <token>
Content-Type: application/json

{
  "useLatestMetrics": true
}
```

#### Get Latest Prediction
```http
GET /api/predictions/latest
Authorization: Bearer <token>
```

#### Get Risk Trends
```http
GET /api/predictions/trends?period=month
Authorization: Bearer <token>
```

## ML Models

### Available Models

1. **Hypertension Risk Prediction** - Random Forest Classifier
2. **Diabetes Risk Prediction** - Logistic Regression
3. **Heart Disease Risk Prediction** - Decision Tree
4. **Obesity-Related Conditions** - Support Vector Machine

### Training Models

To train custom ML models:

```bash
cd ml-service
python train_models.py
```

This will:
- Generate 10,000 synthetic health records
- Train 4 disease prediction models
- Evaluate model accuracy
- Save models to `ml-service/models/`

### Model Performance

- Hypertension: >85% accuracy
- Diabetes: >80% accuracy
- Heart Disease: >75% accuracy
- Obesity: >70% accuracy

## Database Schema

### Users
```javascript
{
  email: String,
  password: String (hashed),
  profile: {
    name: String,
    age: Number,
    gender: String,
    height: Number,
    weight: Number,
    bmi: Number,
    medicalHistory: [String],
    existingConditions: [String],
    activityLevel: String
  }
}
```

### Health Metrics
```javascript
{
  userId: ObjectId,
  date: Date,
  metrics: {
    bloodPressure: { systolic: Number, diastolic: Number },
    bloodSugar: Number,
    cholesterol: { total: Number, ldl: Number, hdl: Number },
    weight: Number,
    temperature: Number,
    heartRate: Number
  }
}
```

### Disease Predictions
```javascript
{
  userId: ObjectId,
  date: Date,
  predictions: [{
    disease: String,
    riskScore: Number,
    likelihood: String,
    factors: [String],
    recommendations: [String]
  }]
}
```

## Environment Variables

```env
# Server Configuration
NODE_ENV=development
PORT=5000

# Database
MONGODB_URI=mongodb://localhost:27017/healthdb

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRE=7d

# ML Service
ML_SERVICE_URL=http://localhost:8000

# CORS
CORS_ORIGIN=http://localhost:8080
```

## Docker Support

```bash
# Build and start all services
docker-compose up

# Stop services
docker-compose down
```

## Testing

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

## Deployment

### Cloud Deployment

The application is ready for deployment to:
- AWS (Elastic Beanstalk, ECS)
- Google Cloud Platform (Cloud Run)
- Azure (App Service)
- Heroku

### Database

- MongoDB Atlas for production
- Configure connection string in environment variables

### ML Service

- Deploy as separate microservice
- Configure scaling based on prediction load

## Security

- JWT token authentication
- Password hashing with bcrypt
- Rate limiting on API endpoints
- Input validation and sanitization
- CORS configuration
- Helmet.js security headers

## License

MIT

## Support

For issues and questions, please open an issue on GitHub.