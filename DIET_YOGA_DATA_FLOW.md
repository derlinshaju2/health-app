# 🔄 Diet & Yoga Module - Complete Data Flow Documentation

## 📊 **System Architecture & Data Flow**

---

## 🏗️ **Overall Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                          │
│  ┌──────────────────────┐  ┌──────────────────────┐      │
│  │   🥗 Diet Tab        │  │   🧘 Yoga Tab        │      │
│  │  • Profile Input     │  │  • Fitness Profile   │      │
│  │  • Recommendations  │  │  • Routine Display   │      │
│  │  • Progress Tracking│  │  • Progress Tracking│      │
│  └──────────────────────┘  └──────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                   CLIENT-SIDE LOGIC                           │
│  • Input validation                                           │
│  • Data formatting                                            │
│  • API request construction                                   │
│  • Response handling and UI update                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                      BACKEND API LAYER                          │
│  ┌───────────────────────────────────────────────────────┐   │
│  │  Authentication Middleware (JWT)                         │   │
│  │  • Verify user token                                     │   │
│  │  • Extract user ID                                      │   │
│  │  • Authorization check                                   │   │
│  └───────────────────────────────────────────────────────┘   │
│                          ↓                                     │
│  ┌───────────────────────────────────────────────────────┐   │
│  │  DIET RECOMMENDATION ENGINE                              │   │
│  │  • BMI analysis                                           │   │
│  │  • Calorie target calculation                            │   │
│  │  • Meal plan generation                                  │   │
│  │  • Food guidelines                                       │   │
│  └───────────────────────────────────────────────────────┘   │
│  ┌───────────────────────────────────────────────────────┐   │
│  │  YOGA RECOMMENDATION ENGINE                             │   │
│  │  • Fitness level assessment                              │   │
│  │  • Routine generation                                    │   │
│  │  • Pose selection                                        │   │
│  │  • Safety precautions                                   │   │
│  └───────────────────────────────────────────────────────┘   │
│  ┌───────────────────────────────────────────────────────┐   │
│  │  PROGRESS TRACKING SYSTEM                               │   │
│  │  • Data storage in MongoDB                               │   │
│  │  • Statistics calculation                                │   │
│  │  • Achievement system                                     │   │
│  │  • Trend analysis                                        │   │
│  └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                    MONGODB DATABASE                             │
│  ┌───────────────────────────────────────────────────────┐   │
│  │  Progress Collection                                     │   │
│  │  • User diet data (calories, water, meals)              │   │
│  │  • User yoga data (duration, poses, difficulty)           │   │
│  │  • Wellness metrics (energy, mood, sleep, stress)       │   │
│  │  • Timestamps and dates                                   │   │
│  │  • Achievements and milestones                            │   │
│  └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                   RESPONSE TO FRONTEND                          │
│  • JSON data formatting                                     │
│  • Success/error messages                                   │
│  • UI update instructions                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📡 **Detailed API Data Flow**

### **1. Diet Recommendation Flow**

```
USER INPUT (Diet Tab)
  ↓
User enters: BMI=28, Age=35, Female, Goal=Weight Loss
  ↓
JavaScript Client
  - Validates input (BMI required)
  - Shows loading state
  - Constructs API request
  ↓
GET /api/diet?bmi=28&age=35&gender=female&goal=weight_loss
Headers: Authorization: Bearer <JWT_TOKEN>
  ↓
Backend Authentication
  - JWT middleware validates token
  - Extracts user ID from token
  - Allows request to proceed
  ↓
Diet Recommendation Engine
  - Analyzes BMI category (overweight)
  - Sets diet type (weight_loss)
  - Calculates calorie target (1600 cal)
  - Adjusts for age (-200 cal for >50)
  - Adjusts for gender (-200 cal for female)
  - Final target: 1200 calories/day
  ↓
Meal Plan Generation
  - Weight loss meal selection
  - High-protein, low-carb focus
  - 3 meals + 2 snacks
  - Portion calculation
  ↓
Food Guidelines
  - Foods to eat: Leafy greens, lean proteins, whole grains
  - Foods to limit: Processed meats, refined carbs
  - Foods to avoid: Trans fats, sugary drinks
  ↓
Water Intake Calculation
  - Base: 8 glasses/day
  - BMI > 25: +1 glass
  - Final: 9 glasses/day
  ↓
Tips Generation
  - Weight loss tips selected
  - "Eat smaller portions more frequently"
  - "Don't skip meals"
  - "Drink water before meals"
  ↓
Response Formatting
{
  status: "success",
  data: {
    userProfile: { bmi: 28, bmiCategory: "overweight" },
    recommendations: {
      dietType: "weight_loss",
      calorieTarget: 1200,
      mealPlan: {...},
      nutritionalGuidelines: {...},
      foodRecommendations: {...},
      waterIntake: 9,
      tips: [...]
    }
  }
}
  ↓
Frontend Display
  - Shows BMI category and calorie target
  - Displays meal plan with calories
  - Shows food guidelines
  - Displays water intake target
  - Shows daily tips
  - Hides loading state
```

### **2. Yoga Recommendation Flow**

```
USER INPUT (Yoga Tab)
  ↓
User enters: Fitness=Beginner, Age=30, Goal=Flexibility
  ↓
JavaScript Client
  - Validates input (all fields optional)
  - Shows loading state
  - Constructs API request
  ↓
GET /api/yoga?fitnessLevel=beginner&age=30&goal=flexibility
Headers: Authorization: Bearer <JWT_TOKEN>
  ↓
Backend Authentication
  - JWT middleware validates token
  - Extracts user ID
  - Allows request to proceed
  ↓
Yoga Recommendation Engine
  - Determines yoga level (beginner)
  - Sets session duration (20 mins)
  - Sets poses count (5 poses)
  - Adjusts for age (no change for age 30)
  ↓
Routine Generation
  - Beginner pose selection
  - Includes: Mountain Pose, Downward Dog, Cat-Cow, Tree, Child's Pose
  - Each pose with duration and benefits
  ↓
Warm-up & Cool-down
  - 5 exercises each (5 mins total)
  - Neck rolls, shoulder circles, arm circles, torso twists, knee circles
  - Seated forward fold, butterfly, reclined twist, corpse pose
  ↓
Breathing Exercises
  - Deep breathing, alternate nostril, ocean breath, skull shining breath
  - Each with duration and instructions
  ↓
Safety Precautions
  - Checks for health conditions (none provided)
  - Adds general tips for beginners
  - "Start with shorter sessions"
  - "Focus on proper alignment"
  ↓
Weekly Schedule Generation
  - Goal: Flexibility-focused schedule
  - Monday: Hatha Yoga (30 mins)
  - Tuesday: Yin Yoga (40 mins)
  - Wednesday: Vinyasa Flow (30 mins)
  - Thursday: Deep Stretch (35 mins)
  - Friday: Restorative (30 mins)
  - Saturday: Ashtanga (30 mins)
  - Sunday: Gentle Flow (25 mins)
  ↓
Tips Generation
  - Beginner tips selected
  - "Practice on empty stomach"
  - "Listen to your body"
  - "Use props as needed"
  ↓
Response Formatting
{
  status: "success",
  data: {
    userProfile: { fitnessLevel: "beginner", age: 30, goal: "flexibility" },
    recommendations: {
      yogaLevel: "beginner",
      sessionDuration: 20,
      posesCount: 5,
      routine: [...],
      warmup: [...],
      cooldown: [...],
      breathing: [...],
      tips: [...],
      precautions: [...],
      weeklySchedule: {...}
    }
  }
}
  ↓
Frontend Display
  - Shows yoga level and session details
  - Displays warm-up exercises with instructions
  - Shows main poses with duration and benefits
  - Displays breathing exercises
  - Shows cool-down exercises
  - Displays weekly schedule
  - Shows tips and precautions
  - Hides loading state
```

### **3. Progress Tracking Flow**

```
USER INPUT (Daily Logging)
  ↓
User enters diet or yoga data
  ↓
JavaScript Client
  - Validates input (at least one metric required)
  - Constructs progress object
  ↓
POST /api/progress
Headers:
  - Authorization: Bearer <JWT_TOKEN>
  - Content-Type: application/json
Body: {
  diet: {
    caloriesConsumed: 1800,
    waterIntake: 8,
    mealsLogged: 3,
    dietNotes: "Felt good today"
  },
  yoga: {
    durationMinutes: 30,
    posesCompleted: 5,
    difficulty: "beginner",
    yogaType: "hatha",
    yogaNotes: "Great session!"
  }
}
  ↓
Backend Authentication
  - JWT middleware validates token
  - Extracts user ID
  - Allows request to proceed
  ↓
Progress Processing
  - Check if progress exists for today's date
  - If exists: Update existing entry
  - If new: Create new Progress document
  ↓
Achievement Checking
  - Check for diet achievements (diet plan followed)
  - Check for yoga achievements (30+ mins, 10+ poses)
  - Check for wellness achievements (high energy, excellent mood)
  - Add earned achievements to progress
  ↓
Database Storage
MongoDB Progress Collection:
{
  userId: ObjectId("..."),
  date: ISODate("2026-04-27"),
  diet: {
    caloriesConsumed: 1800,
    caloriesTarget: 1200,
    waterIntake: 8,
    waterTarget: 9,
    mealsLogged: 3,
    dietPlanFollowed: false,
    dietNotes: "Felt good today"
  },
  yoga: {
    durationMinutes: 30,
    targetMinutes: 30,
    posesCompleted: 5,
    difficulty: "beginner",
    yogaType: "hatha",
    exercisesCompleted: [],
    yogaNotes: "Great session!"
  },
  wellness: {},
  achievements: [
    {
      type: "yoga",
      title: "Dedicated Yogi",
      description: "Completed 30+ minutes of yoga",
      date: ISODate("2026-04-27")
    }
  ],
  createdAt: ISODate("2026-04-27T10:30:00.000Z"),
  updatedAt: ISODate("2026-04-27T10:30:00.000Z")
}
  ↓
Achievement Response
{
  status: "success",
  message: "Progress logged successfully",
  data: <saved_progress_document>
}
  ↓
Frontend Response
  - Shows success message
  - Clears form fields
  - Updates UI (if implemented)
```

---

## 📊 **Statistics Calculation Flow**

```
GET /api/progress/statistics?days=30
  ↓
Backend Processing
  - Calculate date range (last 30 days)
  - Query Progress collection for user
  - Retrieve all progress entries in date range
  ↓
Diet Statistics Calculation
  - Filter entries with diet data
  - Calculate average calories: sum(calories) / count
  - Calculate average water: sum(water) / count
  - Calculate target achievement: (dietPlanFollowed / count) * 100
  ↓
Yoga Statistics Calculation
  - Filter entries with yoga data
  - Calculate total minutes: sum(durationMinutes)
  - Calculate average minutes: totalMinutes / count
  - Calculate target achievement: (duration >= target) / count * 100
  - Determine most common difficulty level
  ↓
Wellness Statistics Calculation
  - Calculate average energy: sum(energyLevel) / count
  - Calculate average sleep: sum(sleepQuality) / count
  - Calculate average stress: sum(stressLevel) / count
  - Count mood occurrences
  - Find most common mood
  ↓
Trend Analysis
  - Compare first half vs second half of data
  - Identify increasing/decreasing patterns
  - Generate trend descriptions
  - Create trend objects
  ↓
Response Formatting
{
  status: "success",
  data: {
    totalDays: 25,
    dateRange: { start: date, end: date },
    dietStats: {
      entries: 20,
      averageCalories: 1650,
      targetAchieved: 75,
      averageWater: 7.5
    },
    yogaStats: {
      entries: 18,
      totalMinutes: 540,
      averageMinutes: 30,
      targetAchieved: 100,
      mostCommonDifficulty: "beginner"
    },
    wellnessStats: {
      entries: 25,
      averageEnergy: 7,
      averageMood: "good",
      averageSleep: 8,
      mostCommonMood: "good"
    },
    trends: [
      {
        type: "yoga_duration",
        trend: "increasing",
        description: "Yoga practice increasing"
      },
      {
        type: "energy_level",
        trend: "improving",
        description: "Energy levels improving"
      }
    ]
  }
}
```

---

## 🗄️ **Database Operations**

### **Create Progress Entry**
```javascript
POST /api/progress
Body: { diet: {...}, yoga: {...} }

MongoDB Operation:
db.progress.findOne({ userId, date: today })

If exists:
  db.progress.updateOne(
    { userId, date: today },
    { $set: { diet: {...}, yoga: {...} } }
  )
If not exists:
  db.progress.create({
    userId, date, diet, yoga,
    createdAt, updatedAt
  )
```

### **Query Progress History**
```javascript
GET /api/progress?limit=30&startDate=2026-04-01&endDate=2026-04-27

MongoDB Operation:
db.progress.find({
  userId,
  date: {
    $gte: ISODate("2026-04-01"),
    $lte: ISODate("2026-04-27")
  }
})
.sort({ date: -1 })
.limit(30)
```

### **Calculate Statistics**
```javascript
GET /api/progress/statistics?days=30

MongoDB Operations:
1. db.progress.countDocuments({ userId, date: range })
2. db.progress.aggregate([
    { $match: { userId, date: range } },
    { $group: {
      _id: null,
      avgCalories: { $avg: "$diet.caloriesConsumed" },
      avgWater: { $avg: "$diet.waterIntake" }
    }}
  ])
```

---

## 🔐 **Security Flow**

### **Authentication & Authorization**
```
Client Request with JWT Token
  ↓
JWT Middleware
  - Extract token from Authorization header
  - Verify token signature
  - Decode token payload
  - Extract user ID and expiration
  ↓
Token Validation
  - Check if token expired
  - Check if user exists in database
  - Validate user permissions
  ↓
Request Processing
  - Add user ID to request object
  - Process request with user context
  - Ensure user can only access their own data
  ↓
Response
  - Return user-specific data only
  - Include security headers
```

---

## 🎨 **Frontend State Management**

### **Tab Navigation**
```
User clicks nav item
  ↓
switchTab('diet') function
  - Remove 'active' class from all tabs
  - Remove 'active' class from all nav items
  - Add 'active' class to diet-tab
  - Add 'active' class to diet nav item
  - Update UI visibility
```

### **Data Display States**
```
Initial State:
  - Show profile input form
  - Hide recommendations display
  - Show loading state

Loading State:
  - Display spinner/loading message
  - Disable form inputs
  - Maintain previous state

Success State:
  - Hide loading state
  - Display recommendations
  - Enable form inputs
  - Show success message (optional)

Error State:
  - Hide loading state
  - Show error message
  - Enable form inputs
  - Provide retry option
```

---

## 📈 **Progress Visualization**

### **Daily Progress Display**
```
Today's Progress
├── Diet Progress
│   ├── Calories: 1800/2000 (90%)
│   ├── Water: 7/8 glasses (87.5%)
│   └── Meals Logged: 3
│
└── Yoga Progress
    ├── Duration: 30/30 mins (100%)
    ├── Poses: 5/8 completed
    └── Difficulty: Beginner
```

### **Weekly Statistics Display**
```
Last 7 Days
├── Diet Stats
│   ├── Average Calories: 1,750
│   ├── Target Achievement: 85%
│   └── Average Water: 7.5 glasses
│
├── Yoga Stats
│   ├── Total Minutes: 210
│   ├── Average Duration: 30 mins
│   └── Target Achievement: 100%
│
└── Wellness Stats
    ├── Energy Level: 7.5/10
    ├── Mood: Mostly Good
    └── Sleep Quality: 8/10
```

---

## 🔄 **Update & Synchronization Flow**

### **Real-time Updates**
```
User saves progress
  ↓
POST /api/progress
  ↓
Database update
  ↓
Immediate response
  ↓
UI update
  - Show success message
  - Clear form
  - Update statistics (if visible)
```

### **Background Synchronization**
```
Tab switch to Diet/Yoga
  ↓
Check for cached recommendations
  ↓
If cache exists:
  - Display cached data immediately
  - Optionally refresh in background
  ↓
If no cache:
  - Show loading state
  - Fetch recommendations from API
  - Cache the results
  - Display recommendations
```

---

## 📱 **Responsive Design Flow**

### **Mobile Adaptation**
```
Screen Width Detection
  ↓
CSS Media Queries
  ├── @media (max-width: 768px)
  │   ├── Stack form inputs vertically
  │   ├── Reduce font sizes
  │   └── Adjust padding
  │
  └── @media (max-width: 480px)
      ├── Single column layout
      ├── Larger touch targets
      └── Simplified navigation
```

---

## 🎯 **Error Handling Flow**

### **API Error Handling**
```
API Call Fails
  ↓
Catch Error
  ↓
Log Error (console.error)
  ↓
Display User-Friendly Message
  - "Failed to get recommendations"
  - "Error: [specific error]"
  ↓
Provide Recovery Options
  - Retry button
  - Return to previous state
  - Contact support option
```

### **Validation Error Handling**
```
Invalid User Input
  ↓
Client-Side Validation
  - Check required fields
  - Validate data ranges
  - Format checking
  ↓
Show Inline Error
  - Highlight problematic field
  - Display error message
  - Prevent form submission
  ↓
Allow Correction
  - Enable form inputs
  - Remove error on valid input
  - Enable submission when valid
```

---

## 🚀 **Performance Optimization**

### **Database Optimization**
```javascript
// Indexes for efficient queries
progressSchema.index({ userId: 1, date: -1 });

// Aggregation pipeline for statistics
db.progress.aggregate([
  { $match: { userId, dateRange } },
  { $group: { _id: "$diet.dietType", count: { $sum: 1 } } }
]);
```

### **Frontend Optimization**
```javascript
// Debounce function for search/filter
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Lazy loading for progress data
function loadProgressData() {
  // Load only when tab is active
  if (document.getElementById('diet-tab').classList.contains('active')) {
    fetchProgressData();
  }
}
```

---

## 📊 **Analytics Data Flow**

### **User Behavior Tracking**
```
User Actions
  - Recommendation requests
  - Progress logging
  - Tab navigation
  - Form interactions
  ↓
Event Tracking
  - Track recommendation types requested
  - Log progress consistency
  - Monitor feature usage
  ↓
Analytics Storage
  - Store in separate analytics collection
  - Aggregate anonymous statistics
  - Generate usage reports
```

### **Progress Trends Analysis**
```
Historical Data Collection
  - Daily progress entries
  - 7-day, 30-day, 90-day windows
  ↓
Trend Calculation
  - Moving averages
  - Growth/decline patterns
  - Seasonal variations
  ↓
Predictive Insights
  - Streak prediction
  - Goal achievement likelihood
  - Risk factor identification
```

---

## 🔄 **End-to-End User Journey**

### **First-Time User Journey**
```
1. User registers/logs in
2. Lands on Home tab
3. Clicks Diet tab
4. Enters profile information (BMI, age, gender, goal)
5. Clicks "Get My Diet Plan"
6. Sees personalized meal plan and recommendations
7. Logs daily diet progress
8. Receives achievement motivation
9. Views progress statistics
10. Continues tracking and improves health
```

### **Returning User Journey**
```
1. User logs in
2. System remembers previous profile data
3. User navigates to Diet or Yoga tab
4. System shows cached or fresh recommendations
5. User logs daily progress
6. System tracks streaks and achievements
7. User views progress trends and statistics
8. User adjusts goals based on progress
9. Recommendations update dynamically
10. Continuous improvement cycle
```

---

## 🎊 **System Success Metrics**

### **Performance Metrics**
- ⚡ **Recommendation Generation:** < 1 second
- 📊 **Progress Logging:** < 500ms
- 📈 **Statistics Calculation:** < 2 seconds
- 🎯 **UI Response Time:** Instant updates
- 📱 **Mobile Performance:** Optimized for all devices

### **User Engagement**
- 🥗 **Diet Plan Usage:** Track recommendation views
- 🧘 **Yoga Plan Usage:** Monitor routine generation
- 📝 **Progress Logging:** Daily active users
- 🏆 **Achievement Unlocks:** Motivation system engagement
- 📈 **Return Rate:** User retention over time

### **Health Outcomes**
- 🎯 **Goal Achievement:** Diet and yoga targets met
- 📊 **Progress Tracking:** Consistent logging habits
- 💪 **Fitness Improvements:** Measurable health gains
- 🧠 **Wellness Enhancement:** Better energy, mood, sleep
- 🏆 **Achievement Earning:** Motivation through rewards

---

## 🔄 **Continuous Improvement Loop**

```
User Feedback → Usage Analytics → System Optimization → Improved Recommendations → Better Health Outcomes
```

---

This **Diet & Yoga Recommendation Module** represents a complete, production-ready health and wellness platform with intelligent recommendations, comprehensive progress tracking, and user engagement features!

**Built for total health transformation** 🥗🧘💪