#!/bin/bash
set -e

echo "=== Step 1: System packages ==="
sudo apt-get update -qq
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev

echo "=== Step 2: Flutter ==="
cd /home/vscode
curl -Lo flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz"
tar xf flutter.tar.xz
rm flutter.tar.xz
export PATH="/home/vscode/flutter/bin:$PATH"
echo 'export PATH="/home/vscode/flutter/bin:$PATH"' >> ~/.bashrc
flutter config --no-analytics
flutter precache --android

echo "=== Step 3: Android SDK ==="
mkdir -p /home/vscode/android-sdk/cmdline-tools
cd /home/vscode/android-sdk/cmdline-tools
curl -Lo cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
unzip -q cmdline-tools.zip
mv cmdline-tools latest
rm cmdline-tools.zip

export ANDROID_SDK_ROOT="/home/vscode/android-sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
echo 'export ANDROID_SDK_ROOT="/home/vscode/android-sdk"' >> ~/.bashrc
echo 'export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"' >> ~/.bashrc

echo "=== Step 4: Android licenses + SDK ==="
yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

echo "=== Step 5: pub get ==="
cd /workspaces/MedVault-App
flutter pub get

echo "=== ALL DONE! Now run: flutter build apk --debug ==="
