# 🔐 Authentication Module Documentation

## 🎯 Purpose
Handles user login, registration, and security for the health_app application.

## 🔧 Features Implemented
✅ **Register new user** - Create account with email, password, and profile information  
✅ **Login existing user** - Authenticate with email and password  
✅ **Password encryption** - Secure bcrypt hashing for password storage  
✅ **JWT token generation** - JSON Web Tokens for secure authentication  
✅ **Logout functionality** - Clear tokens and session data  
✅ **Protected routes** - Middleware to secure private endpoints  
✅ **Token storage** - Secure local storage persistence  
✅ **Auto-authentication** - Check and restore user sessions  

## 📥 Input Data

### Registration
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "profile": {
    "name": "John Doe",
    "age": 28,
    "gender": "male",
    "height": 175,
    "weight": 70
  }
}
```

### Login
```json
{
  "email": "user@example.com", 
  "password": "securePassword123"
}
```

## 📤 Output Data

### Success Response
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "user": {
      "id": "69ec78997e542df469ab6756",
      "email": "user@example.com",
      "profile": {
        "name": "John Doe",
        "bmi": 22.9,
        "activityLevel": "sedentary"
      }
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### JWT Token Structure
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "userId": "69ec78997e542df469ab6756",
    "iat": 1777105058,
    "exp": 1777709858
  }
}
```

## 🔗 Authentication Flow

### 1. Registration Flow
```
User → Register Screen → Enter Details 
  → API Call (POST /api/auth/register)
  → Backend: Validate Email → Check if User Exists
  → Hash Password (bcrypt) → Create User → Generate JWT
  → Return Token + User Data → Store Token Locally
  → Navigate to Dashboard
```

### 2. Login Flow
```
User → Login Screen → Enter Credentials 
  → API Call (POST /api/auth/login)
  → Backend: Find User → Compare Password (bcrypt)
  → Generate JWT → Return Token + User Data
  → Store Token Locally → Navigate to Dashboard
```

### 3. Protected API Flow
```
User → App Action → API Client Adds JWT Header
  → Backend: Verify JWT → Extract User ID → Get User Data
  → Process Request → Return Data
```

### 4. Logout Flow
```
User → Click Logout → Show Confirmation Dialog
  → Clear Local Token → Call Logout API (optional)
  → Navigate to Login Screen
```

## 🔒 Security Features

### Password Security
- **bcrypt hashing** with salt rounds = 10
- **Password validation**: Minimum 6 characters
- **Secure comparison**: Timing-safe comparison

### JWT Security
- **HS256 algorithm** for token signing
- **Token expiration**: 7 days (604800 seconds)
- **Secret key**: Environment variable (JWT_SECRET)
- **Automatic refresh**: Check token validity on app start

### API Security
- **CORS enabled** for development
- **Request validation** using Joi schemas
- **Rate limiting** on API endpoints
- **Protected routes** with authentication middleware
- **401 handling** for unauthorized access

## 📁 File Structure

### Frontend (Flutter)
```
lib/features/auth/
├── data/
│   └── models/
│       └── user_model.dart              # User data model
├── presentation/
│   ├── providers/
│   │   └── auth_provider.dart          # Auth state management
│   └── screens/
│       ├── splash_screen.dart          # Initial loading screen
│       ├── login_screen.dart           # Login UI
│       └── register_screen.dart        # Registration UI
└── [Network layer]
```

### Backend (Node.js)
```
src/
├── controllers/
│   └── authController.js               # Auth logic handlers
├── models/
│   └── User.js                         # User mongoose model
├── routes/
│   └── auth.js                         # Auth API routes
├── middleware/
│   ├── auth.js                         # JWT verification
│   └── validation.js                   # Request validation
└── config/
    └── jwt.js                          # JWT configuration
```

## 🧪 Testing

### Test Credentials
```
Email: authtest@example.com
Password: test123
```

### API Endpoints

#### Register
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "test123",
    "profile": {"name": "New User"}
  }'
```

#### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "authtest@example.com",
    "password": "test123"
  }'
```

#### Protected Route
```bash
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 📱 User Interface

### Login Screen Features
- ✅ Email validation (format check)
- ✅ Password visibility toggle
- ✅ Loading states during authentication
- ✅ Error messaging
- ✅ Navigation to registration
- ✅ Remember me functionality (token persistence)

### Registration Screen Features
- ✅ Full name input
- ✅ Email validation
- ✅ Password strength requirements
- ✅ Confirm password validation
- ✅ Terms and conditions checkbox
- ✅ Real-time validation feedback
- ✅ Loading states

### Dashboard Integration
- ✅ Logout button with confirmation
- ✅ User profile display
- ✅ Auto-authentication on app start
- ✅ Session persistence

## 🚀 Usage Example

### In Flutter Code
```dart
// Login
final authProvider = Provider.of<AuthProvider>(context);
final success = await authProvider.login(
  'user@example.com',
  'password123'
);

if (success) {
  Navigator.pushReplacementNamed(context, '/dashboard');
}

// Check Auth Status
await authProvider.checkAuthStatus();
if (authProvider.isAuthenticated) {
  // User is logged in
}

// Logout
await authProvider.logout();
Navigator.pushReplacementNamed(context, '/login');
```

### API Integration
```dart
// API client automatically adds JWT header
final response = await _apiClient.get('/api/auth/me');

// Manual token usage
final token = await _apiClient.getAuthToken();
```

## 🔧 Configuration

### Environment Variables
```env
JWT_SECRET=your-secret-key-here
JWT_EXPIRE=7d
NODE_ENV=development
```

### API Constants
```dart
static const String baseUrl = 'http://localhost:5000';
static const Duration connectionTimeout = Duration(seconds: 30);
```

## 📊 Status Codes

- **200** - Login successful
- **201** - Registration successful  
- **400** - Validation error / User exists
- **401** - Invalid credentials / Unauthorized
- **500** - Server error

## 🎯 Future Enhancements

- [ ] Social login (Google, Facebook)
- [ ] Password reset functionality
- [ ] Email verification
- [ ] Two-factor authentication
- [ ] Session management
- [ ] OAuth 2.0 integration
- [ ] Biometric authentication (mobile)

## ✅ Testing Checklist

- [x] User can register with valid email and password
- [x] User cannot register with existing email
- [x] User can login with correct credentials
- [x] User cannot login with wrong credentials
- [x] JWT token is generated and stored
- [x] Protected routes require valid JWT
- [x] User can logout successfully
- [x] Token persists across app restarts
- [x] Auto-authentication works on app start
- [x] UI shows loading states
- [x] Error messages are user-friendly

---

**🎉 Authentication Module is fully functional and ready for production use!**