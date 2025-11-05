# Firebase Setup Checklist

## If you see "An error occurred" when registering, check these:

### 1. Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **ie-skill-index**
3. Click on **Authentication** in the left menu
4. Click on **Get Started** (if you see it)
5. Go to **Sign-in method** tab
6. Click on **Email/Password**
7. Toggle **Enable** to ON
8. Click **Save**

### 2. Create Firestore Database

1. In Firebase Console, click on **Firestore Database** in the left menu
2. Click **Create Database**
3. Choose **Start in test mode** (for development)
4. Select a location closest to you
5. Click **Enable**

### 3. Set Firestore Security Rules (for development)

Go to **Firestore Database** > **Rules** tab and use:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Allow authenticated users to read styles and operations
    match /styles/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    match /operations/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    // Allow authenticated users to manage their assessments
    match /assessments/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Try Again

After completing these steps:

1. Refresh your browser (reload the app)
2. Try registering again
3. You should now see a more specific error message if something is still wrong

## Current Error Shows

Now the app will display the actual error message, such as:

- "Auth Error: [code] - [detailed message]"
- This will help identify exactly what's wrong

## Test Registration

Try registering with:

- Name: Test User
- Email: test@example.com
- Password: test123 (at least 6 characters)

If successful, you'll see "Registration successful! Please login."
