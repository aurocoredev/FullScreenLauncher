# FullScreenLauncher

一個為 macOS 打造的全螢幕應用程式啟動器，提供類似手機的資料夾式分類體驗。

A full-screen app launcher for macOS with folder-style categorization, just like your phone.

![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

[![Download](https://img.shields.io/badge/Download-v1.2.0-brightgreen?style=for-the-badge)](https://github.com/aurocoredev/FullScreenLauncher/releases/tag/v1.2.0)

---

**[中文](#中文) | [English](#english)**

---

# 中文

## 功能特色

- **資料夾式瀏覽** - 點擊分類資料夾進入內頁，手機般的直覺體驗
- **全螢幕顯示** - 覆蓋整個螢幕，沉浸式體驗
- **毛玻璃背景** - 精美的視覺效果
- **自動分類** - 應用程式自動分為：生產力工具、開發工具、影音媒體、社交通訊、系統工具、遊戲、其他
- **自訂分類** - 新增、編輯、刪除分類，自由指派 App
- **即時搜尋** - 首頁搜尋所有 App，資料夾內搜尋該分類
- **自訂設定** - 可調整圖標大小、間距、背景透明度
- **啟動行為** - 可選擇啟動 App 後關閉或保持開啟
- **全域快捷鍵** - 預設 `⌘⌥F1`，可自訂修改
- **狀態列圖標** - 方便快速存取
- **多語言支援** - 支援繁體中文與英文介面切換

## 截圖

### 首頁 - 資料夾卡片
![首頁](screenshots/screenshots-01.png)

### 資料夾內頁 - App 列表
![資料夾內頁](screenshots/screenshots-02.png)

### 分類管理
![分類管理](screenshots/screenshots-03.png)

### 設定面板
![設定面板](screenshots/screenshots-04.png)

## 系統需求

- macOS 12.0 (Monterey) 或更高版本
- Apple Silicon (M1/M2/M3) 或 Intel 處理器

## 安裝方式

### 方法一：下載預編譯版本（推薦）

1. **[點此下載 FullScreenLauncher.app.zip](https://github.com/aurocoredev/FullScreenLauncher/releases/download/v1.2.0/FullScreenLauncher.app.zip)**
2. 解壓縮 zip 檔案
3. 將 `FullScreenLauncher.app` 拖曳到「應用程式」資料夾
4. 首次開啟時，右鍵點擊 → 選擇「打開」（因為沒有 Apple 開發者簽名）

> 或前往 [Releases 頁面](https://github.com/aurocoredev/FullScreenLauncher/releases) 查看所有版本

### 方法二：從原始碼編譯

```bash
# 複製專案
git clone https://github.com/aurocoredev/FullScreenLauncher.git
cd FullScreenLauncher

# 使用 build script 編譯
./build.sh

# 或手動編譯
swiftc -o FullScreenLauncher main.swift -framework Cocoa -framework SwiftUI -framework Carbon -O
```

## 使用方式

| 操作 | 功能 |
|------|------|
| `⌘⌥F1` | 全域快捷鍵開啟/關閉（可自訂） |
| 點擊資料夾 | 進入該分類查看 App |
| `ESC` | 返回上一層 / 清空搜尋 / 關閉視窗 |
| 點擊 ⚙️ | 開啟設定面板 |
| 點擊 📁 | 開啟分類管理 |
| 直接輸入 | 搜尋應用程式 |

### ESC 鍵行為

- 在資料夾內且有搜尋文字 → 清空搜尋
- 在資料夾內且無搜尋文字 → 返回首頁
- 在首頁且有搜尋文字 → 清空搜尋
- 在首頁且無搜尋文字 → 關閉視窗

## 設定選項

在設定面板中可調整：

- **圖標大小** - 48px ~ 128px
- **間距** - 10px ~ 60px
- **背景深度** - 10% ~ 90%
- **顯示分類** - 開啟資料夾模式 / 關閉顯示所有 App
- **啟動行為** - 啟動後關閉 / 保持開啟
- **全域快捷鍵** - 自訂您喜歡的快捷鍵組合
- **語言** - 繁體中文 / English

## 開機自動啟動

1. 開啟「系統設定」→「一般」→「登入項目」
2. 點擊「+」按鈕
3. 選擇「FullScreenLauncher.app」

---

# English

## Features

- **Folder-style Browsing** - Click category folders to enter, intuitive like a phone
- **Full-screen Display** - Immersive experience covering the entire screen
- **Frosted Glass Background** - Beautiful visual effects
- **Auto Categorization** - Apps are automatically sorted into: Productivity, Development, Media, Social, Utilities, Games, Other
- **Custom Categories** - Add, edit, delete categories, freely assign apps
- **Instant Search** - Search all apps from home, search within category from folder
- **Customizable Settings** - Adjust icon size, spacing, background opacity
- **Launch Behavior** - Choose to close or stay open after launching an app
- **Global Hotkey** - Default `⌘⌥F1`, customizable
- **Menu Bar Icon** - Quick access from the status bar
- **Multi-language Support** - Switch between Traditional Chinese and English

## Screenshots

### Home - Folder Cards
![Home](screenshots/screenshots-01.png)

### Folder View - App List
![Folder View](screenshots/screenshots-02.png)

### Category Manager
![Category Manager](screenshots/screenshots-03.png)

### Settings Panel
![Settings](screenshots/screenshots-04.png)

## System Requirements

- macOS 12.0 (Monterey) or later
- Apple Silicon (M1/M2/M3) or Intel processor

## Installation

### Option 1: Download Pre-built Version (Recommended)

1. **[Click here to download FullScreenLauncher.app.zip](https://github.com/aurocoredev/FullScreenLauncher/releases/download/v1.2.0/FullScreenLauncher.app.zip)**
2. Unzip the file
3. Drag `FullScreenLauncher.app` to your Applications folder
4. On first launch, right-click → select "Open" (required for unsigned apps)

> Or visit the [Releases page](https://github.com/aurocoredev/FullScreenLauncher/releases) for all versions

### Option 2: Build from Source

```bash
# Clone the project
git clone https://github.com/aurocoredev/FullScreenLauncher.git
cd FullScreenLauncher

# Build with the build script
./build.sh

# Or compile manually
swiftc -o FullScreenLauncher main.swift -framework Cocoa -framework SwiftUI -framework Carbon -O
```

## Usage

| Action | Function |
|--------|----------|
| `⌘⌥F1` | Global hotkey to open/close (customizable) |
| Click folder | Enter category to view apps |
| `ESC` | Go back / Clear search / Close window |
| Click ⚙️ | Open settings panel |
| Click 📁 | Open category manager |
| Start typing | Search applications |

### ESC Key Behavior

- In folder with search text → Clear search
- In folder without search text → Return to home
- At home with search text → Clear search
- At home without search text → Close window

## Settings

Available options in the settings panel:

- **Icon Size** - 48px ~ 128px
- **Spacing** - 10px ~ 60px
- **Background Depth** - 10% ~ 90%
- **Show Categories** - Enable folder mode / Disable to show all apps
- **Launch Behavior** - Close after launch / Stay open
- **Global Hotkey** - Customize your preferred key combination
- **Language** - 繁體中文 / English

## Launch at Login

1. Open "System Settings" → "General" → "Login Items"
2. Click the "+" button
3. Select "FullScreenLauncher.app"

---

## Changelog

### v1.2.1
- Added Chinese/English language switching
- Multi-language support for UI

### v1.2.0
- New folder-style browsing experience
- Click category cards to enter and view apps
- Independent search within folders
- Added launch behavior setting (close/stay open)
- ESC key supports multi-level navigation
- Removed items-per-row setting, now auto-calculated

### v1.1.0
- Added custom category feature
- Added category management interface
- Bug fixes and performance improvements

### v1.0.0
- Initial release

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Issues and Pull Requests are welcome!

## Acknowledgments

Inspired by macOS Launchpad, dedicated to all users who miss a full-screen launcher experience.
