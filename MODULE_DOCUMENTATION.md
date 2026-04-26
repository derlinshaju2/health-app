# Health Monitoring Modules - Complete Documentation

## 📊 Module 1: Health Metrics Tracking

### Overview
Users can track vital health metrics including blood pressure, blood sugar, and cholesterol levels. Data is stored in MongoDB and displayed with history and basic analytics.

### Backend Implementation

#### Model: `health-backend/models/HealthMetrics.js`
```javascript
{
  userId: ObjectId,           // Reference to User
  bloodPressure: {
    systolic: Number,         // mmHg
    diastolic: Number         // mmHg
  },
  bloodSugar: Number,         // mg/dL
  cholesterol: {
    ldl: Number,             // mg/dL (Bad cholesterol)
    hdl: Number,             // mg/dL (Good cholesterol)
    total: Number            // mg/dL
  },
  timestamp: Date,
  notes: String
}
```

#### API Endpoints

**1. Add Health Metrics**
```
POST /api/metrics/add
Authorization: Bearer {token}

Request Body:
{
  "bloodPressure": {
    "systolic": 120,
    "diastolic": 80
  },
  "bloodSugar": 95,
  "cholesterol": {
    "total": 200,
    "ldl": 130,
    "hdl": 50
  },
  "notes": "Optional notes"
}

Response:
{
  "status": "success",
  "message": "Health metrics added successfully",
  "data": { /* created metric */ }
}
```

**2. Get Metrics History**
```
GET /api/metrics/history?limit=50&skip=0
Authorization: Bearer {token}

Response:
{
  "status": "success",
  "data": {
    "metrics": [
      {
        "_id": "...",
        "userId": "...",
        "bloodPressure": { "systolic": 120, "diastolic": 80 },
        "bloodSugar": 95,
        "cholesterol": { "total": 200, "ldl": 130, "hdl": 50 },
        "timestamp": "2026-04-26T10:00:00.000Z"
      }
    ],
    "total": 45,
    "count": 45
  }
}
```

**3. Get Analytics**
```
GET /api/metrics/analytics
Authorization: Bearer {token}

Response:
{
  "status": "success",
  "data": {
    "totalReadings": 45,
    "bloodPressure": {
      "count": 40,
      "avgSystolic": 125,
      "avgDiastolic": 82,
      "latest": { "systolic": 120, "diastolic": 80 }
    },
    "bloodSugar": {
      "count": 45,
      "average": 98,
      "latest": 95
    },
    "cholesterol": {
      "count": 20,
      "avgTotal": 195,
      "latest": { "total": 200, "ldl": 130, "hdl": 50 }
    }
  }
}
```

**4. Delete Metric**
```
DELETE /api/metrics/{metricId}
Authorization: Bearer {token}

Response:
{
  "status": "success",
  "message": "Health metric deleted successfully"
}
```

### Frontend Implementation

#### UI Components
1. **Metrics Form** - Input fields for:
   - Blood Pressure (Systolic/Diastolic)
   - Blood Sugar (mg/dL)
   - Cholesterol (Total, LDL, HDL)

2. **History Display** - Card-based UI showing:
   - Timestamp
   - All recorded values
   - Color-coded display

3. **Analytics Dashboard** - Shows:
   - Average values
   - Latest readings
   - Count of entries

#### JavaScript Functions
```javascript
// Add new health metrics
window.addMetrics()

// Fetch and display history
window.getMetricsHistory()
```

---

## 🤖 Module 2: AI Disease Prediction

### Overview
AI-powered health risk prediction using a Python ML service. The system analyzes health metrics and predicts disease risk levels (Low, Medium, High) with explanations and recommendations.

### Architecture

```
Frontend (app.html)
    ↓
Node.js Backend (/api/predictions/predict)
    ↓
Python ML Service (http://localhost:5001/predict)
    ↓
Risk Analysis + Recommendation
```

### ML Service Implementation

#### File: `ml-service/app.py`

**Dependencies:**
- Flask (Web framework)
- Flask-CORS (Cross-origin requests)
- Gunicorn (Production server)

**Installation:**
```bash
cd ml-service
pip install -r requirements.txt
python app.py
```

**Service runs on:** `http://localhost:5001`

#### ML Service Endpoints

**1. Predict Disease Risk**
```
POST /predict

Request Body:
{
  "bloodPressure": { "systolic": 140, "diastolic": 90 },
  "bloodSugar": 130,
  "bmi": 28.5,
  "cholesterol": { "total": 250, "ldl": 170, "hdl": 35 }
}

Response:
{
  "status": "success",
  "data": {
    "riskLevel": "High",
    "riskScore": 12,
    "riskFactors": [
      "High blood pressure (Hypertension)",
      "High blood sugar (Diabetes range)",
      "Overweight (BMI: 28.5)",
      "High total cholesterol (250 mg/dL)"
    ],
    "recommendation": "Consult a healthcare professional immediately...",
    "color": "#ef4444",
    "timestamp": "2026-04-26T10:00:00.000Z"
  }
}
```

**2. Health Check**
```
GET /health

Response:
{
  "status": "success",
  "message": "AI Prediction Service is running",
  "service": "ML Health Risk Predictor",
  "version": "1.0.0"
}
```

### Prediction Algorithm

The ML service uses a rule-based expert system with the following logic:

#### Blood Pressure Analysis
- **High Risk:** Systolic ≥ 140 or Diastolic ≥ 90 (+3 points)
- **Medium Risk:** Systolic ≥ 120 or Diastolic ≥ 80 (+2 points)
- **Low Risk:** Systolic < 90 or Diastolic < 60 (+1 point)

#### Blood Sugar Analysis
- **High Risk:** ≥ 126 mg/dL (Diabetes range) (+4 points)
- **Medium Risk:** 100-125 mg/dL (Pre-diabetes) (+2 points)
- **Low Risk:** < 70 mg/dL (Hypoglycemia) (+1 point)

#### BMI Analysis
- **High Risk:** BMI ≥ 35 (Obesity Class II) (+4 points)
- **Medium Risk:** BMI 30-34.9 (Obesity Class I) (+3 points)
- **Medium Risk:** BMI 25-29.9 (Overweight) (+2 points)
- **Low Risk:** BMI < 18.5 (Underweight) (+1 point)

#### Cholesterol Analysis
- **High Risk:** Total ≥ 240 mg/dL (+3 points)
- **High Risk:** LDL ≥ 160 mg/dL (+3 points)
- **Medium Risk:** HDL < 40 mg/dL (+2 points)

#### Risk Level Calculation
- **High Risk:** Score ≥ 8 points → Red color (#ef4444)
- **Medium Risk:** Score 4-7 points → Yellow/Orange color (#f59e0b)
- **Low Risk:** Score < 4 points → Green color (#10b981)

### Node.js Backend Integration

#### File: `health-backend/routes/predictions.js`

**Environment Variables:**
```env
ML_SERVICE_URL=http://localhost:5001  # Python ML service URL
```

**Endpoint:**
```
POST /api/predictions/predict
Authorization: Bearer {token}

Request Body: (Forwarded to ML service)
{
  "bloodPressure": { "systolic": 120, "diastolic": 80 },
  "bloodSugar": 95,
  "bmi": 24.5,
  "cholesterol": { "total": 200, "ldl": 100, "hdl": 45 }
}

Response:
{
  "status": "success",
  "data": {
    "riskLevel": "Low",
    "riskScore": 2,
    "riskFactors": ["No significant risk factors"],
    "recommendation": "Your health metrics are within normal ranges...",
    "color": "#10b981"
  }
}
```

**Fallback System:**
If the ML service is unavailable, the backend provides a basic prediction using Node.js logic.

### Frontend Implementation

#### UI Components
1. **Prediction Button** - Triggers AI analysis
2. **Result Display** - Color-coded results:
   - 🔴 High Risk (Red background)
   - 🟡 Medium Risk (Yellow background)
   - 🟢 Low Risk (Green background)

3. **Information Display:**
   - Risk Level with emoji
   - List of risk factors
   - Personalized recommendation
   - Visual color coding

#### JavaScript Functions
```javascript
// Generate AI predictions
window.generatePredictions()

// Display prediction results
function displayPrediction(prediction)
```

### Data Flow

```
1. User clicks "Generate Predictions"
   ↓
2. Frontend fetches latest health metrics from /api/metrics/history
   ↓
3. Frontend fetches user profile from /api/auth/profile (for BMI calculation)
   ↓
4. Frontend sends health data to /api/predictions/predict
   ↓
5. Node.js backend forwards request to Python ML service
   ↓
6. Python ML service analyzes data and returns prediction
   ↓
7. Node.js backend returns prediction to frontend
   ↓
8. Frontend displays color-coded results with recommendations
```

---

## 🚀 Deployment Guide

### 1. Backend Deployment (Vercel)

**Environment Variables:**
```env
MONGODB_URI=mongodb+srv://...
JWT_SECRET=your-secret-key
NODE_ENV=production
ML_SERVICE_URL=https://your-ml-service.com  # ML service URL
```

### 2. ML Service Deployment

**Option A: Render.com**
```bash
# Deploy to Render
render.com deploy ml-service/
```

**Option B: Railway**
```bash
railway up
```

**Option C: AWS EC2**
```bash
# Install Python dependencies
pip install -r requirements.txt

# Run with Gunicorn
gunicorn -w 4 -b 0.0.0.0:5001 app:app
```

### 3. Update ML Service URL

Set `ML_SERVICE_URL` environment variable in Vercel to point to your deployed ML service.

---

## 🔧 Testing

### Test Health Metrics API
```bash
# Add metrics
curl -X POST https://your-app.vercel.app/api/metrics/add \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bloodPressure": {"systolic": 120, "diastolic": 80},
    "bloodSugar": 95,
    "cholesterol": {"total": 200, "ldl": 100, "hdl": 50}
  }'

# Get history
curl https://your-app.vercel.app/api/metrics/history \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test ML Service
```bash
# Test health check
curl http://localhost:5001/health

# Test prediction
curl -X POST http://localhost:5001/predict \
  -H "Content-Type: application/json" \
  -d '{
    "bloodPressure": {"systolic": 140, "diastolic": 90},
    "bloodSugar": 130,
    "bmi": 28.5
  }'
```

---

## 📱 Usage Instructions

### For Users

1. **Add Health Metrics:**
   - Go to "Health Metrics" tab
   - Enter values in the form
   - Click "Save Health Metrics"

2. **View History:**
   - Click "Load History" button
   - View all past entries

3. **Get AI Predictions:**
   - Go to "AI Predictions" tab
   - Click "Generate Predictions"
   - View risk analysis and recommendations

### For Developers

1. **Start Backend:**
   ```bash
   cd health-backend
   npm install
   npm start
   ```

2. **Start ML Service:**
   ```bash
   cd ml-service
   pip install -r requirements.txt
   python app.py
   ```

3. **Start Frontend:**
   ```bash
   # Open app.html in browser
   ```

---

## 🔐 Security Considerations

1. **Authentication Required:** All endpoints require valid JWT token
2. **Data Validation:** Input validation on both frontend and backend
3. **CORS Configuration:** ML service configured to accept requests from your domain
4. **Rate Limiting:** Backend implements rate limiting
5. **HTTPS:** Use HTTPS in production for all services

---

## 📈 Future Enhancements

1. **Machine Learning Model:** Replace rule-based system with trained ML model
2. **Time Series Analysis:** Track health trends over time
3. **Alert System:** Notify users of concerning health patterns
4. **Integration:** Connect with wearable devices
5. **Multi-language:** Support multiple languages
6. **Export Data:** Allow users to export health data

---

## 📞 Support

For issues or questions:
- Check console logs for JavaScript errors
- Verify ML service is running on port 5001
- Check environment variables are set correctly
- Ensure MongoDB connection is working

---

**Version:** 1.0.0
**Last Updated:** 2026-04-26
**Status:** Production Ready ✅