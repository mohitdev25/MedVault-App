#!/bin/bash
set -e

FLUTTER_VERSION="3.24.5"
ANDROID_CMD_VERSION="11076708"

echo "=== Installing dependencies ==="
sudo apt-get update -qq
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev

echo "=== Installing Flutter $FLUTTER_VERSION ==="
cd /home/vscode
if [ ! -d "flutter" ]; then
  curl -Lo flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  tar xf flutter.tar.xz
  rm flutter.tar.xz
fi

export PATH="/home/vscode/flutter/bin:$PATH"
flutter config --no-analytics
flutter precache --android

echo "=== Installing Android SDK ==="
mkdir -p /home/vscode/android-sdk/cmdline-tools
cd /home/vscode/android-sdk/cmdline-tools
if [ ! -d "latest" ]; then
  curl -Lo cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMD_VERSION}_latest.zip"
  unzip -q cmdline-tools.zip
  mv cmdline-tools latest
  rm cmdline-tools.zip
fi

export ANDROID_SDK_ROOT="/home/vscode/android-sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

echo "=== Accepting licenses ==="
yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

echo "=== Running flutter pub get ==="
cd /workspaces/MedVault-App
flutter pub get

echo "=== Flutter doctor ==="
flutter doctor

echo "=== Done! ==="
