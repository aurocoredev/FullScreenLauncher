#!/bin/bash

# FullScreenLauncher 編譯腳本
# Build script for FullScreenLauncher

set -e

echo "🔨 開始編譯 FullScreenLauncher..."

# 最低系統版本以 Info.plist 為準，避免 swiftc 預設用本機系統版本
MIN_MACOS=$(/usr/libexec/PlistBuddy -c "Print :LSMinimumSystemVersion" Info.plist)

# 編譯 Swift 程式碼（Apple Silicon + Intel universal binary）
for ARCH in arm64 x86_64; do
    swiftc -o "FullScreenLauncher-$ARCH" main.swift \
        -framework Cocoa \
        -framework SwiftUI \
        -framework Carbon \
        -target "$ARCH-apple-macos$MIN_MACOS" \
        -O
done
lipo -create -output FullScreenLauncher FullScreenLauncher-arm64 FullScreenLauncher-x86_64
rm FullScreenLauncher-arm64 FullScreenLauncher-x86_64

echo "📦 建立應用程式包..."

# 建立 .app 結構
mkdir -p FullScreenLauncher.app/Contents/MacOS
mkdir -p FullScreenLauncher.app/Contents/Resources

# 移動執行檔
mv FullScreenLauncher FullScreenLauncher.app/Contents/MacOS/

# 複製 Info.plist
cp Info.plist FullScreenLauncher.app/Contents/

# 如果有圖標則複製
if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns FullScreenLauncher.app/Contents/Resources/
    echo "✅ 已加入自訂圖標"
fi

# 簽章（可選）：設定 SIGN_IDENTITY 才會執行，公證流程見 docs/release-signing.md
# 例：export SIGN_IDENTITY="Developer ID Application: 你的名字 (TMW5T9TWGW)"
if [ -n "$SIGN_IDENTITY" ]; then
    echo "🔏 簽章中: $SIGN_IDENTITY"
    # --options runtime 與 --timestamp 都是公證的必要條件
    codesign --force --timestamp --options runtime \
        --sign "$SIGN_IDENTITY" FullScreenLauncher.app
    codesign --verify --strict --verbose=2 FullScreenLauncher.app
    echo "✅ 已簽章"
else
    echo "ℹ️  未簽章（設定 SIGN_IDENTITY 可啟用，見 docs/release-signing.md）"
fi

echo "✅ 編譯完成！"
echo ""
echo "📍 應用程式位置: $(pwd)/FullScreenLauncher.app"
echo ""

# 詢問是否安裝
read -p "是否要安裝到 ~/Applications? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p ~/Applications
    cp -r FullScreenLauncher.app ~/Applications/
    echo "✅ 已安裝到 ~/Applications/FullScreenLauncher.app"
    echo ""
    read -p "是否要現在開啟? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open ~/Applications/FullScreenLauncher.app
    fi
fi

echo "🎉 完成！"
