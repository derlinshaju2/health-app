# 👤 User Profile Module Documentation

## 🎯 Purpose
Stores and manages user personal + health information with automatic BMI calculation and personalized health insights.

## 🔧 Features Implemented

### ✅ **Create Profile**
- Full registration with all personal details
- Real-time BMI preview during registration
- Automatic BMI calculation using standard formula
- Profile validation and error handling
- Immediate account creation and login

### ✅ **Update Profile**
- Edit all profile information
- Real-time BMI recalculation
- Profile image upload
- Data persistence across sessions
- Health recommendations update

### ✅ **View Profile**
- Beautiful profile header with image
- Complete personal information display
- BMI status with color coding
- Health statistics dashboard
- Activity history tracking

### ✅ **Upload Profile Image**
- Drag-and-drop image upload
- Image preview in profile header
- Image storage in localStorage
- Automatic display in header and profile
- Support for all image formats

### ✅ **Auto BMI Calculation**
- **Formula:** `BMI = weight (kg) / height (m)²`
- Real-time calculation during registration
- Automatic recalculation on profile update
- BMI status categorization
- Color-coded BMI display

## 📥 Input Data

### **Required Fields:**
- **Name** - Full name (string)
- **Age** - Age in years (number, 1-120)
- **Gender** - male/female/other (select)
- **Height** - Height in cm (number, 100-250)
- **Weight** - Weight in kg (number, 30-200)
- **Email** - Email address (string, unique)
- **Password** - Password (string, min 6 characters)

### **Optional Fields:**
- Profile image (file upload)
- Activity level
- Medical history
- Existing conditions

## 📤 Output Data

### **BMI Calculation:**
```
BMI = weight (kg) / height (m)²

Example:
Height: 175 cm = 1.75 m
Weight: 70 kg
BMI = 70 / (1.75 × 1.75) = 22.86
```

### **BMI Categories:**
| BMI Range | Status | Color |
|-----------|---------|-------|
| < 18.5 | Underweight | Blue (#3B82F6) |
| 18.5 - 24.9 | Normal Weight | Green (#10B981) |
| 25 - 29.9 | Overweight | Orange (#F59E0B) |
| ≥ 30 | Obese | Red (#EF4444) |

### **Additional Outputs:**
- Personalized health recommendations
- BMI status description
- Health insights based on BMI
- Age-specific recommendations
- Progress tracking data

## 🧮 BMI Formula Implementation

### **JavaScript Code:**
```javascript
function calculateBMI(weight, heightCm) {
    const heightInMeters = heightCm / 100;
    return (weight / (heightInMeters * heightInMeters)).toFixed(1);
}

function getBMIStatus(bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
}
```

### **Examples:**
| Height | Weight | BMI | Status |
|--------|--------|-----|--------|
| 170 cm | 55 kg | 19.0 | Normal Weight |
| 175 cm | 70 kg | 22.9 | Normal Weight |
| 180 cm | 90 kg | 27.8 | Overweight |
| 165 cm | 50 kg | 18.4 | Underweight |

## 🔗 Complete User Flow

### **1. Registration Flow:**
```
User → Enter Details → Real-time BMI Preview
  → Calculate BMI → Show Status
  → Create Account → Save Profile with BMI
  → Auto-login → Show Dashboard
```

### **2. Profile Update Flow:**
```
User → Edit Profile → Change Height/Weight
  → Real-time BMI Recalculation
  → Update Recommendations
  → Save Changes → Refresh Display
```

### **3. Profile Image Upload:**
```
User → Click Camera Icon → Select Image
  → Preview Image → Save to Storage
  → Update Display → Show in Header & Profile
```

## 📊 Profile Dashboard Features

### **Profile Header:**
- Profile image (uploaded or default)
- Full name display
- Email address
- Upload button for image

### **BMI Card:**
- Large BMI value display
- Color-coded status indicator
- Personalized description
- Health recommendations

### **Statistics Grid:**
- Age display
- Gender display
- Height in centimeters
- Weight in kilograms

### **Edit Profile Form:**
- All editable fields
- Real-time BMI updates
- Form validation
- Save changes button

### **Health Recommendations:**
- BMI-based recommendations
- Age-specific advice
- Lifestyle suggestions
- Medical consultation reminders (if needed)

## 🎨 User Interface Features

### **Real-time BMI Preview:**
- Shows BMI during registration
- Updates as user types height/weight
- Color-coded status indicator
- Helps users understand their BMI instantly

### **Profile Image Upload:**
- Click camera icon to upload
- Preview in profile header
- Shows in app header
- Persistent across sessions

### **Color-Coded BMI Display:**
- **Blue** - Underweight
- **Green** - Normal Weight
- **Orange** - Overweight
- **Red** - Obese

### **Responsive Design:**
- Works on mobile and desktop
- Grid layouts for stats
- Touch-friendly buttons
- Smooth animations

## 💾 Data Storage

### **LocalStorage Structure:**
```json
{
  "users": [
    {
      "id": "unique_id",
      "name": "John Doe",
      "email": "john@example.com",
      "password": "hashed_password",
      "age": 28,
      "gender": "male",
      "height": 175,
      "weight": 70,
      "bmi": "22.9",
      "profileImage": "base64_image_data",
      "createdAt": "2026-04-25T10:00:00.000Z",
      "lastLogin": "2026-04-25T10:00:00.000Z",
      "metrics": {
        "weight": [{"date": "...", "value": 70}],
        "calories": [],
        "water": [],
        "activities": []
      },
      "preferences": {
        "notifications": true,
        "darkMode": false
      }
    }
  ],
  "currentUser": { /* current user object */ }
}
```

## 🔐 Security Features

- **Password validation** (min 6 characters)
- **Email uniqueness** check
- **Confirmation password** matching
- **Session management**
- **Data persistence** (localStorage)
- **Profile image** validation

## 🧪 Testing Examples

### **Test Case 1: Normal BMI**
```
Input:
- Name: Test User
- Age: 28
- Gender: male
- Height: 175 cm
- Weight: 70 kg

Expected Output:
- BMI: 22.9
- Status: Normal Weight
- Color: Green
```

### **Test Case 2: Profile Update**
```
Action: Update weight to 85 kg
Expected: BMI recalculated to 27.8, status changes to Overweight
```

### **Test Case 3: Image Upload**
```
Action: Upload profile image
Expected: Image shows in profile header and app header
```

## 🎯 Usage Example

### **Register New User:**
1. Click "Register here"
2. Fill in: Name, Age, Gender, Height, Weight, Email, Password
3. Watch real-time BMI preview
4. Click "Create Profile"
5. See dashboard with calculated BMI

### **View Profile:**
1. Click "Profile" tab
2. See all profile information
3. View BMI with color coding
4. Read personalized recommendations

### **Update Profile:**
1. Go to "Edit Profile" section
2. Change height or weight
3. See BMI update in real-time
4. Click "Update Profile"
5. See changes reflected everywhere

### **Upload Image:**
1. Click camera icon on profile
2. Select image from device
3. See image appear in profile
4. Image persists across sessions

## 📈 BMI Health Insights

### **Underweight (< 18.5):**
- Focus on nutrient-dense foods
- Include strength training
- Build muscle mass
- Consult nutritionist

### **Normal Weight (18.5 - 24.9):**
- Maintain current lifestyle
- Regular monitoring
- Balanced diet
- Continue exercise

### **Overweight (25 - 29.9):**
- Increase physical activity
- Reduce portion sizes
- Limit processed foods
- Focus on whole foods

### **Obese (≥ 30):**
- Consult healthcare provider
- Personalized weight loss plan
- Start low-impact exercises
- Keep food diary

## ✅ All Features Working

The User Profile Module is **fully functional** with:
- ✅ Complete profile creation
- ✅ Real-time BMI calculation
- ✅ Profile image upload
- ✅ Profile editing
- ✅ Data persistence
- ✅ Health recommendations
- ✅ Beautiful UI/UX
- ✅ Mobile responsive

---

**🎉 The User Profile Module provides complete user management with automatic BMI calculation and personalized health insights!**