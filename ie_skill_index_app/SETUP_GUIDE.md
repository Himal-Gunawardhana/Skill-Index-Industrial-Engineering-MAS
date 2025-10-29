# IE Skill Index - Complete Setup & User Guide

## 🎯 Application Overview

**IE Skill Index** is an Industrial Engineering performance tracking application designed specifically for the apparel industry. It enables IE professionals to measure, track, and assess worker performance using standardized metrics.

### Key Features

- ✅ Performance assessment with 10 independent timers
- ✅ Automatic calculation of Efficiency, FTT, SSV, and Skill Level
- ✅ Firebase authentication and real-time database
- ✅ Admin panel for managing master data
- ✅ Assessment history and reporting
- ✅ Role-based access control

---

## 📋 Prerequisites

1. **Flutter SDK**: Version 3.9.2 or higher

   ```bash
   flutter --version
   ```

2. **Firebase Account**: Create at [https://console.firebase.google.com](https://console.firebase.google.com)

3. **Development Tools** (choose one):
   - Android Studio (for Android)
   - Xcode (for iOS/macOS)
   - Chrome (for Web testing)

---

## 🚀 Quick Start Guide

### Step 1: Install Dependencies

Navigate to the project folder and install packages:

```bash
cd "/Users/himalgunawardhana/Documents/dev/IE Skill Index/ie_skill_index_app"
flutter pub get
```

### Step 2: Configure Firebase

#### Method A: Using FlutterFire CLI (Recommended - Automatic)

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Run configuration wizard
flutterfire configure
```

Follow the prompts:

1. Select or create a Firebase project
2. Choose platforms (android, ios, macos, web)
3. CLI will automatically generate `firebase_options.dart`

#### Method B: Manual Configuration

1. **Create Firebase Project**:

   - Go to Firebase Console
   - Click "Add project"
   - Name it: "IE Skill Index"
   - Follow the setup wizard

2. **Enable Authentication**:

   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

3. **Create Firestore Database**:

   - Go to Firestore Database
   - Click "Create database"
   - Start in **test mode** (we'll add rules later)
   - Choose a location closest to your users

4. **Register App for Each Platform**:

   **For Web:**

   - Go to Project Settings → General
   - Click "Web" icon (</>) under "Your apps"
   - Register app with nickname: "IE Skill Index Web"
   - Copy the Firebase config object
   - Update `lib/firebase_options.dart` web section

   **For Android:**

   - Click Android icon
   - Register with package name: `com.example.ie_skill_index_app`
   - Download `google-services.json`
   - Place in `android/app/` directory

   **For iOS:**

   - Click iOS icon
   - Register with bundle ID: `com.example.ieSkillIndexApp`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/` directory

5. **Update firebase_options.dart**:

   Replace the placeholder values in `lib/firebase_options.dart`:

   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'YOUR_API_KEY_HERE',           // From Firebase Console
     appId: 'YOUR_APP_ID_HERE',             // From Firebase Console
     messagingSenderId: 'YOUR_SENDER_ID',    // From Firebase Console
     projectId: 'your-project-id',           // Your Firebase Project ID
     authDomain: 'your-project-id.firebaseapp.com',
     storageBucket: 'your-project-id.appspot.com',
   );
   ```

### Step 3: Set Up Firestore Security Rules

1. Go to Firebase Console → Firestore Database → Rules
2. Replace with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is admin
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
                      (request.auth.uid == userId || isAdmin());
    }

    // Styles collection
    match /styles/{styleId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }

    // Operations collection
    match /operations/{operationId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }

    // Assessments collection
    match /assessments/{assessmentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
                               resource.data.createdBy == request.auth.uid;
    }
  }
}
```

3. Click "Publish"

### Step 4: Run the Application

```bash
# For Web (easiest for testing)
flutter run -d chrome

# For Android
flutter run -d android

# For iOS (macOS only)
flutter run -d ios

# For macOS desktop
flutter run -d macos
```

---

## 👤 User Setup

### Create First Admin User

1. **Run the app**
2. **Register** a new account (this will be your admin account)
3. **Go to Firebase Console**:

   - Firestore Database → `users` collection
   - Find your user document (email will be visible)
   - Click "Edit"
   - Add field: `isAdmin` = `true` (boolean)
   - Save

4. **Log out and log back in** - Admin panel will now be visible

### Create Regular IE Users

**Option 1: Register through app** (Users register themselves)

- They will have IE user role by default

**Option 2: Admin creates** (Future feature - can be added)

- Admin can create users with specific roles

---

## 📝 Initial Data Setup (Admin Task)

After creating your admin account, populate master data:

### 1. Add Styles

1. Login as admin
2. Go to **Admin Panel** → **Styles** tab
3. Click the **+** button
4. Add styles with SMV values:
   - Example: "Basic T-Shirt" - SMV: 0.85
   - Example: "Polo Shirt" - SMV: 1.20
   - Example: "Dress Shirt" - SMV: 2.50

### 2. Add Operations

1. Go to **Operations** tab
2. Click the **+** button
3. Add common operations:
   - "Sewing"
   - "Cutting"
   - "Finishing"
   - "Quality Check"
   - "Packing"

---

## 🎓 Usage Guide

### For IE Users - Creating an Assessment

1. **Login** with your credentials

2. **Click "New Assessment"**

3. **Fill Basic Information**:

   - **Style**: Select from dropdown (SMV auto-displays)
   - **Operation**: Select operation type
   - **Shift**: Choose A or B
   - **Module**: Select module number (1-26)
   - **Team Member**: Enter worker's name
   - **EPF**: Enter employee EPF number
   - **Responsible IE**: Auto-selected (you), but can change

4. **Run Timers**:

   - You have 10 timers available
   - For each task cycle:
     - Press **Play** to start
     - Press **Pause** if needed
     - Press **Stop** when complete
     - Press **Reset** to clear and reuse
   - Run as many timers as needed (minimum 1, maximum 10)
   - Only timers that were run will count in calculations

5. **Enter Quality Data**:

   - **Number of Good Garments**: Enter count of defect-free pieces

6. **Submit**:
   - Click **"Calculate & Save Assessment"**
   - View instant results!

### Understanding Results

**SSV (Standard Second Value)**:

- Formula: SMV × 60
- Standard time in seconds

**Average Time**:

- Sum of all run timer values ÷ Number of run timers
- Only counts timers that were actually used

**Efficiency**:

- Formula: (SSV / Average Time) × 100%
- Shows how close worker is to standard performance
- Higher is better

**FTT (First Time Through)**:

- Formula: (Good Garments / Run Timers) × 100%
- Quality metric
- 100% means all pieces were good

**Skill Level** (1-4):

- Based on FTT and Efficiency
- **Level 1**: FTT 100%, Efficiency < 40% (Beginner)
- **Level 2**: FTT 100%, Efficiency 40-60% (Intermediate)
- **Level 3**: FTT 100%, Efficiency 60-80% (Advanced)
- **Level 4**: FTT 100%, Efficiency > 80% (Expert)

### Viewing Assessment History

1. From home screen, click **"Assessment History"**
2. View all past assessments
3. Tap any assessment to see full details
4. Pull down to refresh

---

## 🔧 Admin Functions

### Managing Styles

**Add Style**:

1. Admin Panel → Styles
2. Click + button
3. Enter style name and SMV value
4. Click "Add"

**Edit Style**:

1. Click edit icon (pencil) on any style
2. Modify name or SMV
3. Click "Update"

**Delete Style**:

1. Click delete icon (trash) on style
2. Confirm deletion

### Managing Operations

Same process as Styles:

- Add, Edit, Delete operations as needed
- Operations will appear in dropdown for all users

---

## 🏗️ Build for Production

### Android APK

```bash
# Build release APK
flutter build apk --release

# Find APK at:
# build/app/outputs/flutter-apk/app-release.apk
```

### iOS App

```bash
# Build iOS
flutter build ios --release

# Then use Xcode to archive and submit to App Store
```

### Web Deployment

```bash
# Build web
flutter build web --release

# Deploy contents of build/web/ to:
# - Firebase Hosting
# - Netlify
# - Vercel
# - Your own server
```

**Firebase Hosting Example**:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
firebase init hosting

# Deploy
firebase deploy --only hosting
```

---

## 🐛 Troubleshooting

### "Firebase not initialized" Error

**Fix**: Ensure `firebase_options.dart` has valid configuration

```bash
# Reconfigure Firebase
flutterfire configure
```

### Timer buttons not working

**Fix**:

- Only one timer can run at a time per index
- Try resetting the timer
- Refresh the screen

### Cannot see Admin Panel

**Fix**:

- Check Firestore: Your user document must have `isAdmin: true`
- Log out and log back in after setting admin role

### Build fails on Android

**Fix**:

```bash
# Clean project
flutter clean
rm -rf android/.gradle
flutter pub get

# Rebuild
flutter build apk
```

### Firestore permission denied

**Fix**:

- Check Firestore Rules are published correctly
- Ensure user is authenticated
- Verify user document exists in `users` collection

---

## 📱 Platform-Specific Notes

### Web

- Works on Chrome, Firefox, Safari, Edge
- Best for testing and admin use
- No app installation needed

### Android

- Minimum SDK: 21 (Android 5.0)
- Works on all Android devices
- Can be distributed via Play Store or direct APK

### iOS

- Requires iOS 11.0+
- Need Apple Developer account for App Store
- Can test on simulator without account

### macOS

- Works natively on macOS 10.14+
- Great for desktop use by admin

---

## 🔐 Security Best Practices

1. **Never commit firebase_options.dart with real credentials** to public repos
2. **Use environment variables** for CI/CD pipelines
3. **Regularly update** Firestore security rules
4. **Review user permissions** periodically
5. **Enable 2FA** on Firebase admin accounts
6. **Backup Firestore data** regularly

---

## 📊 Sample Data for Testing

### Sample Styles

| Style Name        | SMV  |
| ----------------- | ---- |
| Basic T-Shirt     | 0.85 |
| Polo Shirt        | 1.20 |
| Button-Down Shirt | 2.50 |
| Jeans             | 3.00 |
| Hoodie            | 2.80 |

### Sample Operations

- Sewing
- Cutting
- Finishing
- Quality Inspection
- Packing
- Pressing
- Button Attaching

---

## 📞 Support & Contact

For issues, questions, or feature requests:

- Email: [Your support email]
- Documentation: This file
- Firebase Console: Monitor usage and errors

---

## 🔄 Version History

**v1.0.0** (October 28, 2025)

- Initial release
- Core assessment functionality
- Admin panel
- Firebase integration
- Multi-platform support

---

## 📄 License

Proprietary - All Rights Reserved  
© 2025 IE Skill Index

---

**Happy Tracking! 📊✨**
