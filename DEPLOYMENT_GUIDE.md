# 🚀 Deployment Guide - AI Health Monitoring App

## 📋 Step 1: GitHub Repository Setup

### Option A: Manual GitHub Setup (Recommended)

1. **Create GitHub Repository:**
   - Go to https://github.com/new
   - Repository name: `ai-health-monitoring-app`
   - Description: `AI-Driven Health Monitoring Application with Flutter, Node.js, and ML`
   - Make it **Public** (for Vercel free tier)
   - **Don't** initialize with README
   - Click "Create repository"

2. **Push to GitHub:**
   ```bash
   # Add GitHub remote (replace YOUR_USERNAME with your GitHub username)
   git remote add origin https://github.com/YOUR_USERNAME/ai-health-monitoring-app.git
   
   # Push to GitHub
   git branch -M main
   git push -u origin main
   ```

### Option B: Using GitHub CLI

If you have GitHub CLI installed:
```bash
# Login to GitHub
gh auth login

# Create repository and push
gh repo create ai-health-monitoring-app --public --source=. --remote=origin --push
```

---

## 🌐 Step 2: Vercel Deployment

### Deploy to Vercel (Free Web Hosting)

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel:**
   ```bash
   vercel login
   ```

3. **Deploy the Web Version:**
   ```bash
   # From project root
   vercel --prod
   ```

4. **Follow the prompts:**
   - **Set up and deploy?** Y
   - **Which scope?** Select your account
   - **Link to existing project?** N
   - **Project name:** ai-health-monitoring-app
   - **In which directory is your code?** . (current directory)
   - **Want to override settings?** N

5. **Your app will be live at:** `https://ai-health-monitoring-app.vercel.app`

---

## 🔧 Step 3: Environment Configuration

### Vercel Environment Variables

After deployment, set up environment variables:

1. Go to https://vercel.com/dashboard
2. Select your project
3. Go to Settings → Environment Variables
4. Add these variables:

```
NODE_ENV=production
MONGODB_URI=mongodb+srv://<your-atlas-connection-string>
JWT_SECRET=your-production-secret-key
ML_SERVICE_URL=https://your-ml-service-url.com
```

### Backend Deployment Options

#### Option A: Render.com (Free Backend Hosting)

1. Create account at https://render.com
2. Click "New +" → "Web Service"
3. Connect your GitHub repository
4. Settings:
   - **Name:** health-backend-api
   - **Environment:** Node
   - **Build Command:** `cd health-backend && npm install`
   - **Start Command:** `cd health-backend && npm start`
   - **Environment Variables:** Add your MongoDB URI and secrets

#### Option B: Railway.app (Alternative)

1. Go to https://railway.app
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your repository
4. Railway will auto-detect Node.js and set up the backend

#### Option C: Keep Local (Development)

For now, you can run the backend locally:
```bash
cd health-backend
npm run dev
```

Use a tunnel service like ngrok to expose it:
```bash
npm install -g ngrok
ngrok http 5000
```

---

## 📱 Step 4: Mobile App Distribution

### Android APK Build

1. **Build Release APK:**
   ```bash
   cd health_app
   flutter build apk --release
   ```

2. **APK Location:**
   ```
   health_app/build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Distribute Options:**
   - **Direct Download:** Host APK on your website
   - **Google Play:** Publish to Play Store ($25 one-time fee)
   - **Firebase App Distribution:** Free beta testing

---

## 🎯 Step 5: ML Service Deployment

### Deploy Python ML Service

#### Option A: PythonAnywhere (Free Tier)

1. Create account at https://www.pythonanywhere.com
2. Create "Flask" project
3. Upload ML service files
4. Install dependencies: `pip install -r requirements.txt`
5. Configure WSGI for Flask app

#### Option B: Render.com (Python Support)

Render.com also supports Python services:
- Create new Web Service
- Point to `health-backend/ml-service`
- Start command: `python app.py`

---

## ✅ Step 6: Testing Your Deployed App

### Test Web Version
1. Visit your Vercel URL
2. Test registration and login
3. Verify all features work

### Test Backend API
```bash
# Test health endpoint
curl https://your-backend-url.onrender.com/health

# Test registration
curl -X POST https://your-backend-url.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","profile":{"name":"Test User"}}'
```

---

## 🎨 Custom Domain Setup (Optional)

### Add Custom Domain in Vercel

1. Go to Vercel project → Settings → Domains
2. Add your domain (e.g., `health.yourdomain.com`)
3. Update DNS records as instructed
4. SSL certificate is automatic

---

## 📊 Monitoring & Analytics

### Set up Analytics

1. **Vercel Analytics:** Built-in with Vercel
2. **Google Analytics:** Add tracking ID to HTML files
3. **Backend Monitoring:** Use services like Sentry for error tracking

---

## 🔄 CI/CD Pipeline (Optional)

### Automatic Deployments

Vercel automatically deploys when you push to GitHub:
```bash
git add .
git commit -m "Update app"
git push origin main
```

Vercel will detect the push and redeploy automatically.

---

## 🆘 Troubleshooting

### Common Issues

**1. Backend Connection Failed:**
- Check if backend service is running
- Verify environment variables in Vercel
- Check CORS settings

**2. MongoDB Connection Error:**
- Ensure MongoDB Atlas allows connections from anywhere
- Check connection string format
- Verify database user permissions

**3. Build Failed:**
- Check build logs in Vercel dashboard
- Ensure all dependencies are in package.json
- Verify Node.js version compatibility

---

## 📞 Support Links

- **Vercel Docs:** https://vercel.com/docs
- **GitHub Docs:** https://docs.github.com
- **Flutter Deployment:** https://flutter.dev/docs/deployment
- **MongoDB Atlas:** https://docs.atlas.mongodb.com

---

## 🎉 Success Checklist

- ✅ Code pushed to GitHub
- ✅ Web app deployed on Vercel
- ✅ Backend API deployed
- ✅ Environment variables configured
- ✅ Mobile APK built
- ✅ All features tested
- ✅ Custom domain configured (optional)
- ✅ Monitoring set up (optional)

**Your AI Health Monitoring App is now live!** 🚀🏥