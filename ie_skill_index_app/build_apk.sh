#!/bin/bash

echo "🔨 Building IE Skill Index APK..."
echo "=================================="
echo ""

cd "/Users/himalgunawardhana/Documents/dev/IE Skill Index/ie_skill_index_app"

echo "📦 Running Flutter build..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ APK built successfully!"
    echo ""
    echo "📱 APK Location:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📊 APK Size:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print "   " $5}'
    echo ""
    echo "🎉 You can now install this APK on your Android device!"
    echo ""
    echo "To install:"
    echo "1. Copy the APK to your phone"
    echo "2. Open it on your phone"
    echo "3. Allow 'Install from unknown sources' if prompted"
    echo "4. Click Install"
else
    echo ""
    echo "❌ Build failed! Check the error messages above."
    exit 1
fi
