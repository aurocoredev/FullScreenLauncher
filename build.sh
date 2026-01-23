#!/bin/bash

# FullScreenLauncher 編譯腳本
# Build script for FullScreenLauncher

set -e

echo "🔨 開始編譯 FullScreenLauncher..."

# 編譯 Swift 程式碼
swiftc -o FullScreenLauncher main.swift \
    -framework Cocoa \
    -framework SwiftUI \
    -framework Carbon \
    -O

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
