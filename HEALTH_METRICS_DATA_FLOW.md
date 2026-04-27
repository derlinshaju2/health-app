# Health Metrics Tracking Module - Data Flow Documentation

## 📊 Overview
The Health Metrics Tracking Module allows users to monitor vital health indicators including blood pressure, blood sugar, and cholesterol levels with comprehensive historical tracking and analytics.

## 🏗️ Architecture

### **Backend Structure**
```
health-backend/
├── models/
│   └── HealthMetrics.js          # MongoDB schema
├── routes/
│   └── metrics.js                # API endpoints
└── src/
    └── app.js                    # Express app configuration
```

### **Frontend Structure**
```
index.html (root & public/)
├── Metrics Tab UI               # User interface
├── JavaScript Functions         # Client-side logic
└── API Integration             # Backend communication
```

## 🔄 Data Flow Diagram

```
┌───────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                          │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  METRICS TAB                                            │  │
│  │  • Blood Pressure Form (Systolic/Diastolic)            │  │
│  │  • Blood Sugar Form (mg/dL)                            │  │
│  │  • Cholesterol Form (LDL/HDL/Total)                    │  │
│  │  • Notes Field                                          │  │
│  │  • History Display                                      │  │
│  │  • Analytics Dashboard                                  │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │  User Action    │
                    │  Add Metrics    │
                    └─────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│                     CLIENT-SIDE LOGIC                           │
│  • Input validation                                           │
│  • Data formatting                                            │
│  • Token management (localStorage)                            │
│  • API request construction                                   │
└───────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │   POST Request  │
                    │ /api/metrics/add│
                    └─────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│                      BACKEND API                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  AUTHENTICATION MIDDLEWARE                               │  │
│  │  • Verify JWT token                                      │  │
│  │  • Extract user ID                                       │  │
│  │  • Authorization check                                   │  │
│  └─────────────────────────────────────────────────────────┘  │
│                              ↓                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  VALIDATION                                              │  │
│  │  • Required field check                                  │  │
│  │  • Data type validation                                  │  │
│  │  • Range validation                                      │  │
│  └─────────────────────────────────────────────────────────┘  │
│                              ↓                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  DATABASE OPERATION                                      │  │
│  │  • Create HealthMetrics document                        │  │
│  │  • Link to user ID                                       │  │
│  │  • Add timestamp                                         │  │
│  │  • Save to MongoDB                                       │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │   MongoDB       │
                    │   Database      │
                    └─────────────────┘
                              ↓
                    ┌─────────────────┐
                    │  Response       │
                    │  Success/Error  │
                    └─────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│                   FRONTEND PROCESSING                           │
│  • Display success/error message                               │
│  • Clear form fields                                           │
│  • Refresh metrics history                                     │
│  • Update analytics dashboard                                 │
└───────────────────────────────────────────────────────────────┘
```

## 📡 API Endpoints

### **1. POST /api/metrics/add**
**Purpose:** Add new health metrics entry

**Request:**
```javascript
POST /api/metrics/add
Headers: {
  "Authorization": "Bearer <JWT_TOKEN>",
  "Content-Type": "application/json"
}
Body: {
  "bloodPressure": {
    "systolic": 120,    // Optional: Top number
    "diastolic": 80     // Optional: Bottom number
  },
  "bloodSugar": 95,      // Optional: mg/dL
  "cholesterol": {
    "ldl": 100,         // Optional: Bad cholesterol
    "hdl": 50,          // Optional: Good cholesterol
    "total": 200        // Optional: Total cholesterol
  },
  "notes": "After morning walk"  // Optional: User notes
}
```

**Response:**
```javascript
{
  "status": "success",
  "message": "Health metrics added successfully",
  "data": {
    "_id": "metric_id",
    "userId": "user_id",
    "bloodPressure": { "systolic": 120, "diastolic": 80 },
    "bloodSugar": 95,
    "cholesterol": { "ldl": 100, "hdl": 50, "total": 200 },
    "notes": "After morning walk",
    "timestamp": "2026-04-27T10:30:00.000Z",
    "createdAt": "2026-04-27T10:30:00.000Z",
    "updatedAt": "2026-04-27T10:30:00.000Z"
  }
}
```

### **2. GET /api/metrics/history**
**Purpose:** Retrieve user's health metrics history

**Request:**
```javascript
GET /api/metrics/history?limit=50&skip=0&startDate=2026-04-01&endDate=2026-04-27
Headers: {
  "Authorization": "Bearer <JWT_TOKEN>"
}
```

**Response:**
```javascript
{
  "status": "success",
  "message": "Health metrics retrieved successfully",
  "data": {
    "metrics": [
      {
        "_id": "metric_id",
        "userId": "user_id",
        "bloodPressure": { "systolic": 120, "diastolic": 80 },
        "bloodSugar": 95,
        "timestamp": "2026-04-27T10:30:00.000Z"
      }
    ],
    "pagination": {
      "total": 25,
      "limit": 50,
      "skip": 0,
      "hasMore": false
    }
  }
}
```

### **3. GET /api/metrics/analytics**
**Purpose:** Get analytics and trends for health metrics

**Request:**
```javascript
GET /api/metrics/analytics?days=30
Headers: {
  "Authorization": "Bearer <JWT_TOKEN>"
}
```

**Response:**
```javascript
{
  "status": "success",
  "message": "Health metrics analytics retrieved successfully",
  "data": {
    "totalEntries": 45,
    "dateRange": {
      "start": "2026-03-28T00:00:00.000Z",
      "end": "2026-04-27T00:00:00.000Z",
      "days": 30
    },
    "bloodPressure": {
      "readings": [/* metric objects */],
      "average": { "systolic": 118, "diastolic": 78 },
      "highest": { "systolic": 130, "diastolic": 85 },
      "lowest": { "systolic": 110, "diastolic": 70 }
    },
    "bloodSugar": {
      "readings": [/* metric objects */],
      "average": 92,
      "highest": 110,
      "lowest": 80
    },
    "cholesterol": {
      "ldl": { "readings": [], "average": 95 },
      "hdl": { "readings": [], "average": 55 },
      "total": { "readings": [], "average": 190 }
    }
  }
}
```

### **4. DELETE /api/metrics/:id**
**Purpose:** Delete a specific health metrics entry

**Request:**
```javascript
DELETE /api/metrics/:id
Headers: {
  "Authorization": "Bearer <JWT_TOKEN>"
}
```

**Response:**
```javascript
{
  "status": "success",
  "message": "Health metrics deleted successfully"
}
```

## 🗄️ Database Schema

### **HealthMetrics Collection**
```javascript
{
  _id: ObjectId,              // Auto-generated unique ID
  userId: ObjectId,           // Reference to User collection
  bloodPressure: {
    systolic: Number,         // Top BP number (mmHg)
    diastolic: Number         // Bottom BP number (mmHg)
  },
  bloodSugar: Number,         // Blood sugar level (mg/dL)
  cholesterol: {
    ldl: Number,             // LDL cholesterol (mg/dL)
    hdl: Number,             // HDL cholesterol (mg/dL)
    total: Number            // Total cholesterol (mg/dL)
  },
  notes: String,             // Optional user notes
  timestamp: Date,           // When the metrics were recorded
  createdAt: Date,           // Auto-generated creation timestamp
  updatedAt: Date            // Auto-generated update timestamp
}
```

**Indexes:**
- `{ userId: 1, timestamp: -1 }` - Efficient user queries with sorting

## 🎨 Frontend Components

### **1. Metrics Input Form**
```javascript
// Form Fields
- BP Systolic Input      // Top blood pressure number
- BP Diastolic Input     // Bottom blood pressure number
- Blood Sugar Input      // Blood sugar level
- Cholesterol LDL Input  // Bad cholesterol
- Cholesterol HDL Input  // Good cholesterol
- Cholesterol Total Input // Total cholesterol
- Notes Textarea         // Optional notes
- Save Button           // Triggers addHealthMetrics()
```

### **2. History Display**
```javascript
// Components
- Metrics History List   // Shows chronological entries
- Individual Metric Cards // Formatted display of each entry
- Date/Time Stamps      // When metrics were recorded
- Delete Buttons        // Remove individual entries (future feature)
```

### **3. Analytics Dashboard**
```javascript
// Display Elements
- 30-Day Summary Card   // Overview of recent trends
- Blood Pressure Stats  // Average, highest, lowest
- Blood Sugar Stats     // Average, highest, lowest
- Cholesterol Stats     // LDL, HDL, Total averages
- Visual Indicators     // Color-coded health ranges
```

## 🔒 Security & Authentication

### **Authentication Flow**
1. **Token Storage:** JWT stored in `localStorage.getItem('auth_token')`
2. **Request Headers:** Every API call includes `Authorization: Bearer <token>`
3. **Middleware:** `authenticateToken` middleware validates JWT
4. **User Extraction:** User ID extracted from decoded token
5. **Authorization:** Users can only access their own metrics

### **Security Measures**
- ✅ JWT authentication required for all endpoints
- ✅ User-specific data isolation (userId filtering)
- ✅ Input validation and sanitization
- ✅ Rate limiting on API endpoints
- ✅ CORS protection
- ✅ Helmet.js security headers

## 📊 Data Processing & Analytics

### **Analytics Calculations**

#### **Blood Pressure Analysis**
```javascript
// Average Calculation
average.systolic = sum(all_systolic) / count
average.diastolic = sum(all_diastolic) / count

// Range Calculation
highest.systolic = max(all_systolic)
highest.diastolic = max(all_diastolic)
lowest.systolic = min(all_systolic)
lowest.diastolic = min(all_diastolic)
```

#### **Blood Sugar Analysis**
```javascript
// Average Calculation
average = sum(all_blood_sugar) / count

// Range Calculation
highest = max(all_blood_sugar)
lowest = min(all_blood_sugar)
```

#### **Cholesterol Analysis**
```javascript
// Per-type Average
ldl.average = sum(all_ldl) / count
hdl.average = sum(all_hdl) / count
total.average = sum(all_total) / count
```

## 🚀 User Journey

### **Adding Health Metrics**
1. User navigates to "Metrics" tab
2. Fills in one or more health metrics
3. Clicks "Save Health Metrics" button
4. Client validates input (at least one metric required)
5. JWT token retrieved from localStorage
6. POST request sent to `/api/metrics/add`
7. Backend authenticates and validates
8. Data stored in MongoDB
9. Success response returned
10. UI updates: form cleared, history refreshed
11. Analytics dashboard updated with new data

### **Viewing History**
1. User switches to "Metrics" tab
2. `loadMetricsHistory()` triggered automatically
3. Parallel API calls:
   - GET `/api/metrics/history?limit=20`
   - GET `/api/metrics/analytics?days=30`
4. Data received and formatted
5. History displayed in chronological order
6. Analytics shown in summary card
7. Real-time data visualization

## ⚡ Performance Optimizations

### **Database Optimization**
- Indexed queries on `userId` and `timestamp`
- Limited result sets with pagination
- Efficient aggregation for analytics
- Lean projections for history queries

### **Frontend Optimization**
- Parallel API requests (history + analytics)
- Debounced input handling (future enhancement)
- Lazy loading of historical data
- Local state management for instant UI updates

### **API Optimization**
- Response compression
- Efficient error handling
- Graceful degradation
- Timeout handling

## 🔧 Error Handling

### **Common Error Scenarios**

#### **Authentication Errors**
```javascript
// 401 Unauthorized
{
  "status": "error",
  "message": "Invalid or expired token"
}
// Solution: Redirect to login
```

#### **Validation Errors**
```javascript
// 400 Bad Request
{
  "status": "error",
  "message": "At least one metric (blood pressure, blood sugar, or cholesterol) is required"
}
// Solution: Show user-friendly error message
```

#### **Network Errors**
```javascript
// Connection timeout
{
  "status": "error",
  "message": "Failed to connect to server"
}
// Solution: Retry mechanism, offline mode
```

## 📈 Future Enhancements

### **Planned Features**
- 📊 Advanced charts and graphs
- 📱 Mobile app integration
- 🔔 Smart notifications and alerts
- 📤 Data export (PDF, CSV)
- 🤖 AI-powered health insights
- 💊 Medication tracking
- 🏃 Exercise integration
- 🍽️ Diet tracking integration
- 👨‍⚕️ Doctor/healthcare provider sharing
- 🌍 Multi-language support

### **Technical Improvements**
- Real-time WebSocket updates
- Offline-first architecture
- Advanced analytics with trends
- Predictive health insights
- Integration with wearable devices
- HIPAA compliance enhancements

---

## 📞 Support & Maintenance

### **Monitoring**
- API response times
- Error rates
- Database query performance
- User engagement metrics

### **Maintenance**
- Regular database backups
- Index optimization
- Security updates
- Performance tuning

This Health Metrics Tracking Module provides a comprehensive foundation for monitoring vital health indicators with room for extensive future enhancements.