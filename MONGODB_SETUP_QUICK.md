# 🍃 MongoDB Setup Guide for AI Health App

## Step 1: Create Account (2 minutes)

1. **Open browser and go to**: https://www.mongodb.com/cloud/atlas
2. **Click**: "Try Free" or "Start Free" button
3. **Fill in registration form**:
   - Email address
   - Password
   - Or sign up with Google/GitHub
4. **Verify** your email if required

## Step 2: Create Free Cluster (3 minutes)

1. **After login**, click "Build a Database" or "Create Cluster"
2. **Choose plan**: Select **FREE** (M0 Sandbox - 512 MB storage)
3. **Configure cluster**:
   - Cloud Provider: AWS (recommended)
   - Region: Choose closest to you
     - US East (Virginia) - for USA users
     - Europe (Ireland) - for European users
     - Asia Pacific (Singapore) - for Asian users
4. **Cluster name**: Enter `healthdb` (or keep default)
5. **Click**: "Create Cluster"
6. **Wait 2-3 minutes** for cluster to be created (you'll see green checkmark)

## Step 3: Create Database User (2 minutes)

1. **Click**: "Database Access" in left sidebar menu
2. **Click**: "Add New Database User" button
3. **Fill in the form**:
   - Username: `healthapp`
   - Password: Click "Autogenerate Secure Password"
   - **IMPORTANT**: Copy and save this password somewhere safe!
4. **Database User Privileges**: Leave as "Read and write to any database"
5. **Click**: "Create User"

## Step 4: Allow Network Access (1 minute)

1. **Click**: "Network Access" in left sidebar menu
2. **Click**: "Add IP Address" button
3. **Choose**: "Allow Access from Anywhere" (this sets 0.0.0.0/0)
4. **Click**: "Confirm"
5. **Why**: This allows your Vercel app to connect from anywhere

## Step 5: Get Connection String (1 minute)

1. **Click**: "Database" in left sidebar menu
2. **Find your cluster** (healthdb or default name)
3. **Click**: "Connect" button on your cluster
4. **Choose**: "Connect your application"
5. **Driver**: Select "Node.js"
6. **Version**: Select "5.5 or later" (or latest available)
7. **Copy** the connection string

**Your connection string looks like:**
```
mongodb+srv://healthapp:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
```

## Step 6: Update Connection String

1. **Replace** `<password>` with your actual database password (from Step 3)
2. **Add** `/healthdb` before the `?` to specify database name

**Final connection string:**
```
mongodb+srv://healthapp:abc123xyz789@cluster0.xxxxx.mongodb.net/healthdb?retryWrites=true&w=majority
```

## Step 7: Add to Vercel (2 minutes)

1. **Go to**: https://vercel.com/dashboard
2. **Find and click**: `health-app` project
3. **Go to**: Settings → Environment Variables
4. **Click**: "Add New" button
5. **Add these 3 variables**:

### Variable 1: MONGODB_URI
- **Key/Name**: `MONGODB_URI`
- **Value**: Paste your final connection string from Step 6
- **Environments**: Check all (Production, Preview, Development)
- **Click**: "Save"

### Variable 2: JWT_SECRET
- **Key/Name**: `JWT_SECRET`
- **Value**: Go to https://www.uuidgenerator.net/api/version4 and copy the UUID
- **Example**: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`
- **Environments**: Check all
- **Click**: "Save"

### Variable 3: NODE_ENV
- **Key/Name**: `NODE_ENV`
- **Value**: `production`
- **Environments**: Check Production only
- **Click**: "Save"

## Step 8: Redeploy Your App (1 minute)

1. **In Vercel dashboard**, go to "Deployments" tab
2. **Find** your latest deployment
3. **Click**: the three dots (⋯) menu
4. **Select**: "Redeploy"
5. **Wait 1-2 minutes** for redeployment to complete

## Step 9: Test Your App (2 minutes)

1. **Visit**: https://health-app-orpin-three.vercel.app
2. **Create Account**:
   - Name: Test User
   - Email: test@example.com
   - Password: test123
3. **Click**: Create Account
4. **Login** with your credentials
5. **Test Features**:
   - Add health metrics (BP: 120/80, Blood Sugar: 95)
   - Generate AI predictions
   - Get diet recommendations
   - Start yoga session

---

## ✅ Setup Complete!

Your app is now fully functional with:
- User registration and login
- Health data storage
- AI predictions
- All features working

---

## 🆘 Troubleshooting

### "MongoDB connection failed"
- Check MONGODB_URI is correct (password replaced)
- Verify cluster is running (not paused)
- Ensure IP whitelist includes 0.0.0.0/0

### "User registration failed"
- Check JWT_SECRET is set (min 32 characters)
- Verify NODE_ENV = production
- Check Vercel deployment logs

### "Cannot save data"
- Ensure database name in connection string matches
- Check cluster status in MongoDB Atlas
- Verify user permissions in Database Access

---

## 📞 Need Help?

- MongoDB Atlas Documentation: https://docs.atlas.mongodb.com/
- MongoDB Support: Available in your Atlas dashboard
- Vercel Documentation: https://vercel.com/docs

---

**Your AI Health Monitoring app will be fully functional after these steps!**

Let me know if you need help with any specific step.
