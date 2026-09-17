# FullScreenLauncher 競品分析 — 2026-09-11

> 範圍：與 Remix-Design/LaunchOS 逐項比較，並調查 GitHub 上較熱門的 Launchpad 替代專案，整理可借鏡之處。
> 資料來源：`gh api` / `gh search` / 各專案 README 與原始碼 / 官網（皆為 2026-09-11 當日抓取）。星數為當日數字。

---

## 0. TL;DR

1. **LaunchOS 是閉源付費產品**：$11.99 起買斷，只支援 macOS 26+，走「完美複刻 Launchpad」路線。GitHub repo 只是產品介紹頁，沒有程式碼可以比
2. **開源龍頭是 LaunchNext**：2,999★、GPL-3.0、macOS 26+、約 43k 行。整個領域有 10 個以上 Launchpad 複刻品，非常擁擠
3. **你的「自動分類資料夾首頁」在競品中很少見**：只有 QuickLaunch 的一鍵整理和 lporg 的 `default` 沾上邊，LaunchOS 也沒有。這是護城河，應該加碼，不要轉向複刻 Launchpad
4. **必備功能 13 項你有 4 項**：最急的缺口是 Enter 啟動 / 方向鍵、點背景關閉、在地化名稱、右鍵選單，都是小工程
5. **盤點發現 8 項技術債**：T1–T3（每次開啟都同步重掃、ID 不穩定、分類每次重複載入 plist）直接拖慢開啟速度，而速度正是 LaunchOS V2 和 LaunchNext 最近主打的點
6. **發佈與曝光是零**：README 下載連結 404、repo 沒有 description 也沒有 topics，在 GitHub 上幾乎不可能被搜到
7. **宣稱的相容性與實際不符**（review 補充，**已修正**）：README / Info.plist 寫 macOS 12+ 與 Intel，但建置產物其實是 `minos 26.0`、只有 arm64，程式碼也有 12 處 macOS 14/15 API 沒加版本保護。另有 4 個持久化 / 互動 bug 一併修掉，見 §1.2

---

## 1. 你的專案現況（以程式碼為準）

| 項目 | 現況 |
|---|---|
| 規模 | 單檔 `main.swift` 2409 行，SwiftUI + AppKit bridge + Carbon hotkey，無外部依賴 |
| 最低系統 | Info.plist 寫 macOS 12，但修正前 `swiftc` 沒指定 target，產物是 **`minos 26.0`、只有 arm64**（見 §1.2 R1，已修正） |
| 授權 / 熱度 | MIT / 1★、0 issue；最後一次 push 2026-03-29 |
| 發佈 | GitHub 只有 **v1.1.0**（2026-01-23）；README 連到的 **v1.2.0 下載連結實測 HTTP 404**；Info.plist 版本仍是 `1.0`；本機無 git tag；未簽章 / 未公證 |
| UX 模型 | 首頁「分類資料夾卡片」→ 點進資料夾看 App 格線；可切成平鋪全部 App。**垂直捲動**（ScrollView + LazyVGrid），非 Launchpad 式分頁 |
| 自動分類 | 三層：手動指派 → `LSApplicationCategoryType` → 關鍵字比對；10 個預設分類。**這是你最獨特的點**（見 §4） |
| 搜尋 | `localizedCaseInsensitiveContains` 子字串比對；首頁搜全部、資料夾內搜該分類 |
| 鍵盤 | 只處理 ESC（多層返回）。**無 Enter 啟動第一個結果、無方向鍵選取** |
| 觸發方式 | Carbon 全域快捷鍵（預設 ⌘⌥F1）、狀態列圖示 |
| App 偵測 | 掃 4 個目錄 + `/Applications`、`~/Applications` 下一層子目錄；`DispatchSource` 監聽頂層目錄變動（0.5s debounce） |
| 設定 | 圖標大小、間距、背景深度、分類開關、啟動後行為、快捷鍵、語言（繁中/英） |
| 視窗 | borderless、`.screenSaver` level、`NSScreen.main`、`.canJoinAllSpaces` |

### 1.1 盤點時順便發現的技術債（與競品「效能」主軸直接相關）

> 行號以 commit `a7494f0`（修正前）為準。

| # | 問題 | 位置 | 影響 |
|---|---|---|---|
| T1 | 每次 `showWindow()` 都呼叫 `refresh()` → **主執行緒同步**重掃所有目錄並重新 `NSWorkspace.icon(forFile:)` | `main.swift:2376`, `:858`, `:684` | 每次按快捷鍵開啟都有延遲；已有 DirectoryMonitor，此呼叫多餘 |
| T2 | `AppItem.id = UUID()` 每次掃描重新產生 | `main.swift:666` | 每次 refresh SwiftUI 視為全新清單，整片重建、無 diff |
| T3 | `AppItem.category` 是計算屬性 → 每次存取都 `NSDictionary(contentsOfFile:)` **重讀 Info.plist**，無快取；`folderGroups` / `activeFolder` / `filteredFolderApps` 層層重算 | `main.swift:671`, `:475-477`, `:803-831` | 資料夾內每打一個字 ≈ 2×N 次重複的 Info.plist 載入呼叫（N = App 數）；實際磁碟 I/O 與延遲尚未量測（OS 檔案快取可能吸收大部分） |
| T4 | 顯示名稱取自檔名（`Calculator`），未用 `FileManager.displayName(atPath:)` | `main.swift:702`, `:713` | 中文系統下系統 App 顯示英文名，且搜「計算機」「系統設定」找不到 |
| T5 | 開在 `NSScreen.main`，不是游標所在螢幕 | `main.swift:2348`, `:2368` | 多螢幕使用者體驗差 |
| T6 | 快捷鍵錄製每次 `addLocalMonitorForEvents` 都沒保存/移除 | `main.swift:1085` | monitor 洩漏（與上一個 commit 修的 ESC 重複註冊同類問題）。**已修正**，併入 R5 |
| T7 | `setActivationPolicy(.regular)` 覆蓋了 Info.plist 的 `LSUIElement=true` | `main.swift:2408` | 實際會出現 Dock 圖示，與 CLAUDE.md「無 Dock 圖示」描述不符（可能是刻意，需確認） |
| T8 | ESC 關閉只 `orderOut`，未 `NSApp.hide`；啟動 App 路徑則有 `hide` | `main.swift:2314`, `:854` | ESC 關閉後焦點不會自動還給原本的 App |

### 1.2 Review 補充：相容性與持久化問題（2026-09-11 已修正）

原報告漏掉這幾項。以下都已先對照程式碼確認成立再修改（行號以 `a7494f0` 為準）。

| # | 問題 | 位置 | 修法 | 驗證 |
|---|---|---|---|---|
| R1 | 宣稱 macOS 12，但有 12 處 API 需要 macOS 14/15：`symbolEffect`、`.rotate`、雙參數 `onChange`，都沒加版本保護；`build.sh` 也沒指定 target，產物是 `minos 26.0`、只有 arm64 | `main.swift:887` 等 12 處、`build.sh` | 新增 `compat*` View helper，舊系統略過動畫（`.rotate` 在 macOS 14 退回 bounce）；`build.sh` 從 Info.plist 讀最低版本，編 arm64 + x86_64 再用 lipo 合成 universal | macOS 12 目標型別檢查從 15 個 error 變成 0 error、0 warning；兩個架構的 `vtool` 都顯示 `minos 12.0` |
| R2 | 每次啟動都執行 `migrateAddNewDefaultCategories()`，分不出「舊版沒有」和「使用者刪掉」，刪掉的預設分類重開就復活 | `main.swift:389` | 改成記錄使用者已見過的預設分類 key（`seenDefaultCategoryKeys`），只補從未見過的。舊使用者沒有這筆紀錄時，視為已見過 eeaa720 之前的 7 個預設分類。連帶修正兩點：分類被刪後比對不到的 App 退回「其他」，否則會從資料夾中消失；「其他」不可刪除 | harness A–G 共 10 項通過 |
| R3 | 分類管理頁每一列的 `onAppear` 都完整掃描一次（含載入所有圖示）；10 個分類就掃 10 次。數量也只在出現時算一次，改了指派不會更新 | `main.swift:1295`、`:1579` | 分類管理頁與 App 選擇 sheet 都改用 `LauncherViewModel.shared.apps`，由上層一次算出各分類數量；分類或指派變動時自動重算 | 型別檢查通過；剩下的全量掃描只在 ViewModel 初始化與 `refresh()` |
| R4 | ESC 沒有先處理設定 / 分類面板，會直接關掉整個視窗，且 `showSettings` 保持為 true，下次開啟面板還在；sheet 開著時也一樣 | `main.swift:2292` | 抽出 `handleEscape`，依序處理：sheet（交給它自己的取消鍵）→ 快捷鍵錄製 → 設定面板 → 分類面板 → 資料夾搜尋 → 資料夾 → 首頁搜尋 → 主視窗；`showWindow()` 開啟時也重設兩個面板 | harness 7 項通過（直接呼叫 `handleEscape`） |
| R5 | `registerHotkey()` 先解除舊的再註冊新的，失敗時不復原也不提示，但新組合已寫入設定 → 設定看起來成功，其實叫不出來 | `main.swift:2215` | `HotkeyManager.update` 改成先註冊新組合、成功才解除舊的，失敗時舊的仍有效；錄製抽成 `HotkeyRecorder`：失敗時不寫入設定並顯示原因，ESC 取消錄製（原本會把 ESC 本身錄成全域快捷鍵），monitor 用完即移除（順便修掉 T6） | harness 8 項通過；以外部註冊佔用組合模擬衝突，得到 `-9878` |

**GUI smoke test（commit `d4173d5`，已安裝到 `~/Applications`）：**

這個環境沒有輔助使用與螢幕錄製權限，無法從外部操作已安裝的 app。改用 in-process harness：跑真正的 `AppDelegate`、全螢幕視窗、SwiftUI sheet 與 ESC monitor，用 `NSApp.postEvent` 送鍵盤事件給自己，並擷取自己的視窗。唯一的改動是三個 sheet 的 `@State` 初始值改由測試開啟。

| 情境 | 結果 |
|---|---|
| ESC 關閉三種 sheet（新增分類 / 編輯分類 / App 選擇） | ✅ 三種都是 attached sheet，按 ESC 只關 sheet，分類面板與主視窗保留（**R4 假設已驗證**） |
| 快捷鍵錄製中按 ESC | ✅ 只取消錄製，設定面板保留 |
| 快捷鍵註冊失敗 | ✅ 設定維持 ⌘⌥F1；顯示「此快捷鍵已被佔用，已保留原本的快捷鍵」；系統層探針（同程序再註冊 ⌘⌥F1 得到 `-9878`）確認舊快捷鍵仍在註冊狀態 |
| 刪除分類後重啟（兩個獨立行程） | ✅「瀏覽器」沒有復活 |
| 重新指派後數量即時更新 | ✅ 由 snapshot 目視確認：開發工具 12 → 11、首頁「其他」3 → 4。harness 用 AX tree 讀文字失敗，屬測試工具問題 |
| 已安裝的 app | 正常執行、無 crash report；migration 已寫入 `seenDefaultCategoryKeys`（10 個） |

**已知限制：**
- **R5 的失敗路徑在目前設定下不會被第三方衝突觸發**（2026-09-17 以兩個 bundled .app 實測，macOS 26.6.2）：

  | A（先註冊） | B（後註冊） | B 的結果 |
  |---|---|---|
  | 一般 | 一般 | `noErr` |
  | `kEventHotKeyExclusive` | 一般 | `noErr` |
  | 一般 | `kEventHotKeyExclusive` | `noErr` |
  | `kEventHotKeyExclusive` | `kEventHotKeyExclusive` | **`-9878`** |

  - `eventHotKeyExistsErr` 只在**雙方都用 `kEventHotKeyExclusive`** 時出現
  - 本專案目前以 option `0`（非 exclusive）註冊，所以第三方 app 的衝突不會回報錯誤
  - 註冊系統保留的 ⌘Space 也回傳 `noErr`（因此才需要 `CopySymbolicHotKeys` 預先比對）
  - 同一程序重複註冊會得到 `-9878`（`update()` 的交易式更新即以此驗證）
  - 若改用 `kEventHotKeyExclusive` 註冊，可偵測到同樣採 exclusive 的第三方 app；
    但對非 exclusive 的第三方仍然無感（case 3），且啟動時若真的衝突，
    快捷鍵會註冊失敗而不是與對方共存 —— 尚未決定是否要改
  - 所以使用者選到被其他 app 或系統佔用的組合時，會「設定成功但按了沒反應」
  - **已於 `680daf6` 補上錄製階段的驗證**：
    - 比對 `CopySymbolicHotKeys()`（本機實測 170 個啟用中的系統快捷鍵），擋掉 ⌘Space 這類組合
    - 要求至少一個修飾鍵，F1–F20 除外；無修飾鍵的一般按鍵會攔截全系統輸入
    - `keyCodeToString` 補上 F13–F20，不再顯示成 `Key80`
    - harness 新增 6 項測試（拒絕 A / ` / ⌘Space，接受 F6 與 ⌃⌘L，F19 顯示正確），全數通過
    - 仍有極限：**其他 app 註冊的快捷鍵無法偵測**，這是 Carbon API 的限制
    - 現有設定不受影響（只在錄製時驗證）；實測你目前的 ⌘/ 不在系統快捷鍵清單中
- 沒有在真實的 macOS 12–15 或 Intel 機器上執行；實體鍵盤操作（真正按下全域快捷鍵）仍需手動確認
- R2 對舊使用者有一次性副作用：若使用者在修正前刪過 design / education / browsers，第一次執行新版時會再補回一次，之後刪除就不會再復活。沒有歷史紀錄，無法分辨這種情況

---

## 2. vs LaunchOS

### 2.1 LaunchOS 基本事實

- **不是開源專案**。GitHub repo 只放產品介紹 + 收 issue（README 明寫 "not an open-source product"）。40★、8 issues
- Remix Design 出品；DMG（約 9 MB）或 `brew install --cask launchos`；不上 App Store；Paddle 收款；線上啟用 + 裝置管理
- 版本 v2.3.0（2026-08-21）；**最低 macOS 26**
- 價格：Basic 免費；Pro 買斷 1 台 $11.99 / 2 台 $18.99 / 5 台 $35.99（取自官網 JS 設定，實際結帳金額未驗證）；7 天試用
- 20 種語言
- Homebrew 安裝數：30 天 201 / 90 天 682 / 365 天 3,068
- V2（2026-05-26）號稱整個重寫（README 說 SwiftUI → AppKit），支援 120Hz+，但**官網沒有任何具體效能數字**
- 有「發文換 Pro」推廣活動 → 社群好評有部分是誘因驅動；找不到獨立媒體評測，比較文都出自競品

### 2.2 功能逐項比較

| 功能 | FullScreenLauncher | LaunchOS 免費版 | LaunchOS Pro |
|---|---|---|---|
| 價格 / 授權 | 免費 MIT 開源 | 免費閉源 | $11.99 起買斷 |
| 最低系統 | **macOS 12** | macOS 26 | macOS 26 |
| 版面模型 | 分類資料夾卡片 + 垂直捲動 | 經典 Launchpad 分頁格線 | + 垂直捲動、視窗模式 |
| **依類別自動分組** | ✅ 三層（手動 / 原生類別 / 關鍵字） | ❌ | ❌（Reorganize 只依名稱 / 安裝時間 / 最後開啟 / 顏色排序） |
| 匯入原生 Launchpad 版面 | ❌ | ✅ | ✅ |
| 拖曳排序、拖曳疊成資料夾 | ❌ | ✅ | ✅ |
| 拖曳到 Dock | ❌ | ✅ | ✅ |
| 右鍵選單 | ❌ | ✅ | ✅ |
| 全域快捷鍵 | ✅ | ✅ | ✅ |
| 觸控板手勢 / 熱角 / F4 | ❌ | ❌ | ✅ |
| 自訂格線 | △ 圖標大小 + 間距，欄數自動算 | ❌ | ✅ 最多 15×15 |
| 隱藏 App / 改名 / 自訂掃描目錄 | ❌ | ❌ | ✅ |
| 完整移除 App | ❌ | ❌ | ✅ |
| 搜尋 | 子字串（檔名） | 縮寫、駝峰、拼音（官網未標層級） | 同左 |
| 鍵盤導航 | 只有 ESC | ✅ 方向鍵、⌘←/→ 翻頁 | ✅ |
| 版面備份 / 還原 | ❌ | ✅（1.4.0 起） | ✅ |
| 顯示在哪個螢幕 | 只有主螢幕 | 主螢幕 / 使用中螢幕 / 游標所在螢幕 | 同左 |
| 背景 | 模糊 + 透明度 | 自訂背景、動態桌布、模糊強度 | 同左 |
| App 內更新 | ❌ | ✅ | ✅ |
| 多語系 | 2 種 | 20 種 | 20 種 |

### 2.3 LaunchOS 的 roadmap 透露了什麼（依 changelog 順序）

0.9.x 熱角 → App 內更新 / 自訂背景 → **匯入原生 Launchpad DB** → 1.0 自訂名稱 → 1.1 隱藏 App → 1.2 觸控板手勢 / 自訂 App 來源 → 1.3 自訂排序、欄列分開設定 → 1.4 版面備份 → 1.5 裝置管理 / F4 → **2.0 重寫、120Hz** → 2.1 移除 App → 2.2 視窗模式 → 2.3 Reorganize

- 使用者最先要的是**「讓我無痛搬家」**（匯入原生版面）與**「讓我控制看到什麼」**（隱藏、改名、排序）
- 1.5.1–1.5.7、2.1.3 幾乎都在修觸控板手勢 → **手勢是維護黑洞**

### 2.4 LaunchOS 使用者抱怨（GitHub issues）

- #3 想自訂間距 / padding / 格線最大寬度 → 開發者拒絕（「盡量開箱即用」）。**你已經有這個功能**
- #5 一次隱藏多個 App；#6 重新排列頁面太麻煩；#8 資料夾動畫速度可調
- #4 點 App 名稱會誤觸改名
- #7 某個 App 明明有效也被 Spotlight 索引，卻不在格線裡（無回應）→ 閉源掃描邏輯不透明
- #1 隱藏選單列圖示後找不到設定入口

### 2.5 小結

- LaunchOS 的核心賣點是「**保留 Launchpad 的肌肉記憶**」，本質上是在複刻 Launchpad
- 你的核心賣點是「**自動整理成手機式分類資料夾**」，定位不同，不需要正面硬拚「像不像 Launchpad」
- 你可以打的缺口：
  - **自動分類**：LaunchOS 沒有，這是最大的差異化
  - **免費開源**：LaunchOS 的熱角、隱藏、格線、改名都鎖在 Pro
  - **掃描邏輯透明**：對應 #7 這類「App 不見了」的問題
  - 系統範圍（macOS 12+ vs 26+）只算小優勢：macOS 12–15 本來就有原生 Launchpad，這群人要的是原生沒有的「自動分類」，不是 Launchpad 替代品

---

## 3. 熱門開源替代專案

### 3.1 版圖總覽（依星數）

| 專案 | ★ | 授權 | 技術 | 最低 macOS | UX 模型 | 特色 | 發佈 |
|---|---|---|---|---|---|---|---|
| [RoversX/LaunchNext](https://github.com/RoversX/LaunchNext) | 2,999 | GPL-3.0 | SwiftUI + AppKit CALayer 格線、SwiftData，約 43k 行 | 26 | 經典分頁 | 匯入原生 DB、排序式拼音/縮寫搜尋、熱角、4/5 指捏合、搖桿、CLI、14 語系 | zip + Homebrew tap，靠 GitHub API 檢查更新 |
| [ggkevinnnn/LaunchNow](https://github.com/ggkevinnnn/LaunchNow) | 830 | GPL-3.0 | SwiftUI + SwiftData | — | 全螢幕 + 視窗兩種 | LaunchNext 的上游；4 指捏合 | zip |
| [blacktop/lporg](https://github.com/blacktop/lporg) | 402 | **MIT** | Go CLI | README 寫測到 14 | 不是啟動器，直接改原生 Launchpad DB | YAML 存 / 載版面；`default` 依 Apple 類別自動建資料夾 | Homebrew tap（最後 release 2024-06） |
| [trey-a-12/LaunchBack](https://github.com/trey-a-12/LaunchBack) | 244 | 無 | SwiftUI | — | 分頁 7×5 | 最早推出（2025-06），2025-08 後停更 | 未簽章 DMG |
| [Launchie](https://github.com/nick-friedrich/launchie-launchpad-replacement-mac-os) | 209 | 閉源（repo 只有 README） | — | 26 | 分頁 + Spaces + 常用列 + 列表 | 熱角、依使用頻率排序搜尋結果、開在游標所在螢幕 | 公證 DMG、官方 Homebrew cask、Mac App Store |
| [Punshnut/macos-launchy](https://github.com/Punshnut/macos-launchy) | 173 | **MIT** | SwiftUI + AppKit NSPanel，18.7k 行 | 13 | 分頁全螢幕 + 浮動小視窗 | 40 語系、熱角、媒體鍵、Ctrl+1–9 跳頁、自動備份、讀在地化名稱 + 轉拼音搜尋 | 公證、Sparkle |
| [kristof12345/Launchpad](https://github.com/kristof12345/Launchpad) | 139 | 付費 source-available | Swift | — | 分頁，2–20 欄 | 匯入原生 DB | 未簽章 zip |
| [Ryan-the-hito/Raspberry](https://github.com/Ryan-the-hito/Raspberry) | 110 | GPL-3.0 | PyQt6 + pyobjc | 15（限 Apple Silicon） | 分頁，右鍵分組 | 內附 lporg 來匯入舊版面 | DMG |
| LaunchOS | 40 | 閉源 | AppKit | 26 | 經典分頁 | 見 §2 | DMG + 官方 cask |
| 小型專案（≤11★） | | | | | | Launchpad_Back（GPL，分頁跟手指走，有單元測試）、MovApp（附解除安裝）、QuickLaunch（拼音首字母、**一鍵依類別整理**、IconCache） | |

> 另一條路線是 Spotlight / Raycast 式的「搜尋優先」啟動器：[ospfranco/sol](https://github.com/ospfranco/sol) 3.1k★、[SuperCmd](https://github.com/SuperCmdLabs/SuperCmd) 3.2k★、[tinycast](https://github.com/abue-ammar/tinycast) 2.8k★。它們不做格線，不是直接競品，但說明「打字就能啟動」是剛需。

### 3.2 必備功能對照（幾乎每個競品都有）

| 必備功能 | 你有嗎 |
|---|---|
| 全域快捷鍵 | ✅ |
| 直接打字搜尋，**Enter 啟動第一個結果** | ❌ 有搜尋，但 Enter 不會啟動 |
| 方向鍵選取 | ❌ |
| 拖曳排序 | ❌ |
| 把 App 拖到另一個 App 上建資料夾 | ❌（改用分類管理介面指派） |
| 分頁 + 頁點 | ❌（垂直捲動） |
| 多層 ESC | ✅ |
| 模糊背景 | ✅ |
| **點背景空白處關閉** | ❌ |
| 隱藏 App | ❌ |
| 右鍵選單 | ❌ |
| 開機自動啟動 | ❌（README 教手動加登入項目） |
| 自動偵測新安裝的 App | ✅ |

13 項裡你有 4 項。其中拖曳、分頁屬於「Launchpad 模型」，跟你的分類模型不一定相容（見 §4 不建議做的部分）。其餘缺口都是小工程。

**反過來看**：以「分類」為主的首頁在競品中很少見，只有 QuickLaunch 的一鍵整理和 lporg 的 `default` 指令沾上邊。

### 3.3 值得知道的實作技巧

- **原生 Launchpad 資料庫**
  - 路徑：`$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`，SQLite，資料表 `apps` / `groups` / `items`
  - `items.type`：1 = root、2 = 資料夾、3 = 頁、4 = App
  - **已在你這台 Mac 實測**：
    - 檔案停在 2026-01-12，是升級到 26 之前留下的
    - 128 個 App、6 個資料夾：`其他`、`遊戲`、`office`、`Adobe`、`DaVinci Resolve`、`遠端工具`
  - 升級上來的 Mac 有這個檔案，全新安裝的 Mac 沒有
- **格線渲染效能**
  - LaunchNext 把 SwiftUI `LazyVGrid` 換成「每個圖示一個 CALayer」的 AppKit 格線（issue #208，提案者實測約快 4 倍）
  - LaunchOS V2 也從 SwiftUI 換成 AppKit
  - 可見 SwiftUI 格線放上百個圖示確實是瓶頸，但你應該**先修 T1–T3**，這些成本低很多
- **搜尋排序**（LaunchNext）
  - 優先順序：完全符合 > 開頭符合 > 單字開頭符合 > 縮寫 > 字母依序出現 > 子字串
  - 中日韓名稱用 `CFStringTokenizer` 轉成拼音 / 羅馬字，連同首字母一起比對
  - **輸入法組字中暫停鍵盤導航**，避免注音選字時按 Enter 就啟動了 App
- **在地化名稱**
  - Launchy 讀 `InfoPlist.loctable`
  - 最簡單的做法是 `FileManager.default.displayName(atPath:)` 或 `URLResourceKey.localizedNameKey`（對應 T4、LaunchNext #5）
- **圖示效能**
  - QuickLaunch：每個圖示只繪製一次成 128px bitmap，避免 SwiftUI 每一幀重畫多重解析度圖示
  - Launchy：用 NSCache 並設記憶體上限
  - LaunchNext：掃描期間先顯示佔位圖
- **視窗**
  - Launchy：non-activating `NSPanel`，`.mainMenu` level 加 `.moveToActiveSpace`，按鍵轉送給搜尋框，不搶焦點（對應 T8）
  - LaunchNext：啟動時就建好視窗，之後只淡入；開在游標所在螢幕；點 Dock 圖示可以切換開關
- **分頁手勢**
  - 翻頁門檻：滑過 15% 寬度，或快速一滑
  - 邊緣有橡皮筋回彈效果
  - 滑鼠滾輪另寫一套邏輯；Magic Mouse 沒有手勢階段資訊，也要分開處理
  - 這是 LaunchNext 抱怨最多的區域
- **熱角**：用 global mouse-moved monitor，加 1 秒冷卻（Launchy 是 MIT，可參考）
- **常用列**：用 `NSWorkspace.didLaunchApplicationNotification` 計算每個 App 的開啟次數

### 3.4 LaunchNext 使用者抱怨（該避開的坑）

1. 滾輪 / 觸控板翻頁失效或方向相反：#159、#28、#144、#65、#241
2. 拖放的各種異常與閃退：#44、#236、#162、#161
3. 捏合手勢在外接觸控板上不穩定：#231、#239、#216
4. **第三方 App 名稱語言顯示錯誤**：#5（留言最多，21 則）→ 你也有這個問題（T4）
5. 安裝門檻：大家要 Homebrew（#119）、未簽章版本被 Gatekeeper 擋（#2）
6. 想要更多開啟方式：熱角（#213）、F4 會開到 Spotlight（#157）
7. **點外面不會關掉資料夾或視窗**：#62、#47、#127 → 你也缺
8. 視覺細節：標籤間距、圖示模糊、純色背景、垂直捲動

### 3.5 授權：哪些程式碼能直接參考

| 可以複用程式碼（保留 MIT 聲明） | 只能參考做法，不能複製程式碼 |
|---|---|
| Launchy、lporg | GPL-3.0：LaunchNext、LaunchNow、Raspberry、Launchpad_Back<br>沒有 LICENSE 檔：LaunchBack、MovApp、QuickLaunch（README 寫 MIT 但 repo 裡沒有授權檔）<br>閉源 / 付費：LaunchOS、Launchie、kristof12345/Launchpad |

---

## 4. 借鏡清單（依優先度）

### 4.0 定位建議

Launchpad 複刻品已經有 10 個以上：開源有 LaunchNext（3k★），付費有 LaunchOS 和 Launchie。在「像不像 Launchpad」這個戰場，你沒有勝算，也沒必要去拼。

建議主打**「會自己整理的 Launchpad」**：
- 自動分類是你的護城河，應該加碼，不要轉向複刻
- 其他工程都拿來補「必備功能」和效能

### P0 — 先把地基打好（每項都是 S 級，合計約 1–2 天）

| # | 項目 | 做法 | 參考 |
|---|---|---|---|
| 1 | 修 T1–T3 效能債 | 見下方「P0 #1 的兩個實作陷阱」；`AppItem` 用 path 當 id；圖示先繪成固定尺寸 bitmap 放進 NSCache | QuickLaunch IconCache、Launchy（MIT） |
| 2 | 在地化名稱（T4） | `FileManager.displayName(atPath:)`；搜尋時同時比對在地名稱與英文檔名 | Launchy、LaunchNext #5 |
| 3 | Enter 啟動第一個結果 + 方向鍵選取 | 輸入法組字中（`hasMarkedText`）不攔截，注音使用者很需要 | LaunchNext、Launchie changelog |
| 4 | 點背景關閉、關閉時交還焦點（T8） | 背景加 `onTapGesture`；關閉改用 `NSApp.hide(nil)`，或像 Launchy 改成 non-activating NSPanel | LaunchNext #62/#47/#127 |
| 5 | 開在游標所在螢幕（T5） | 用 `NSEvent.mouseLocation` 找出游標所在的 `NSScreen` | Launchy `ScreenProvider.swift`（MIT，16 行） |
| 6 | 修發佈與曝光 | 修 README 的 404 連結；補 v1.2.x release 與 tag；Info.plist 版本號改對；**repo 加 description 與 topics**（目前 description 是 null、topics 是空的，`gh search repos "launchpad alternative"` 完全找不到你） | — |

#### P0 #1 的兩個實作陷阱（review 補充）

1. **不能直接拿掉開啟時的 `refresh()`，全靠現有的監聽。**
   - `DirectoryMonitor` 只監聽頂層目錄的 `.write` / `.rename`，但掃描範圍包含 `/Applications`、`~/Applications` 下一層子目錄
   - 在既有子目錄（例如 `/Applications/Adobe Photoshop 2026/`）裡新增或移除 App，頂層目錄不會變動，會漏掉更新
   - 做法二選一：
     - 補齊監聽：改用 FSEvents stream 遞迴監聽，或對每個子目錄也開 source
     - 保留開啟時重新驗證，但移到背景 queue、以 path 做 diff，只在有差異時回主執行緒更新
2. **分類快取必須在分類變動時失效。**
   - 會影響分類結果的操作：手動指派（`setAppCategory`）、新增 / 編輯 / 刪除分類、`resetToDefaults`
   - 單純「掃描時算一次」會讓分類管理的變更沒辦法立刻反映
   - 建議只快取昂貴的部分：每個 App path 的「自動分類 key」（讀 Info.plist + 關鍵字比對的結果，只和 App bundle 有關）
   - 查詢時再即時合成：手動指派 map → `findCategory(byKey:)` → 退回「其他」，這幾步都只是記憶體內的字典查詢
   - 這樣分類編輯不需要讓快取失效，只有 App 本身新增、移除或更新時才需要

### P1 — 放大差異化（S–M）

| # | 項目 | 為什麼 | 大小 |
|---|---|---|---|
| 7 | 右鍵選單：在 Finder 顯示 / 複製路徑 / **移到分類…** / 隱藏 | 「移到分類」直接改 `appCategoryMap`，比開分類管理面板快很多，也等於在強化你的核心賣點 | S |
| 8 | **匯入原生 Launchpad 資料夾，轉成分類** | 你這台 Mac 的 DB 還在，6 個資料夾可以一鍵轉成分類。用系統內建的 `SQLite3`，不違反「無外部依賴」。schema 可參考 lporg（MIT） | M |
| 9 | 首頁加「常用 / 最近」一列 | 資料夾式首頁最大的弱點是常用 App 要多點一層。Launchie、QuickLaunch 都有 | S |
| 10 | 拼音 / 縮寫搜尋 + 結果排序 | `applyingTransform(.toLatin)` 再去掉聲調，macOS 12 就能用。排序規則：完全符合 > 開頭符合 > 縮寫 > 子字串。台灣使用者主要受益的其實是 #2 的在地化名稱，拼音是加分項 | S–M |
| 11 | 設定 + 分類 JSON 匯出 / 匯入 | 分類是使用者花心力整理出來的，LaunchOS 到 1.4 才補上備份 | S |
| 12 | 開機自動啟動 | `SMAppService.mainApp`（macOS 13+），macOS 12 維持文字說明 | S |

### P2 — 看需求再做（M–L）

- 熱角（Launchy 是 MIT，可參考；1 秒冷卻，可能要權限）
- 隱藏 App、自訂掃描目錄（對應 LaunchOS #7 那種「App 不見了」的問題）
- 資料夾內拖曳排序
- 公證 DMG + 自建 Homebrew tap：公證需要 Apple Developer 帳號（$99/年）；不公證的話，至少在 README 寫上 `xattr -cr` 的步驟
- 開啟動畫（淡入 + 輕微縮放）；macOS 26 的 `glassEffect` 要做 fallback

### 不建議做

- **私有 MultitouchSupport 捏合手勢**：LaunchNext #231/#239 還沒解決，LaunchOS 有 7 個版本都在修手勢
- **解除安裝功能**：需要管理員權限，風險高。改成右鍵「用 AppCleaner 開啟」就好
- **為了像 Launchpad 而做分頁 + 自由拖曳建資料夾**：這是 LaunchNext 的主場，也是它 issue 最多的地方；而且和你的「自動分類」模型衝突（手動拖出來的資料夾要怎麼和自動分類共存？）
- 只有 macOS 26 才有、又沒有 fallback 的 API

### 附註

- CLAUDE.md 寫 Carbon `RegisterEventHotKey`「需要輔助使用權限」。MovApp 的 release notes 說不需要，一般認知也是不需要，但**尚未實測**，建議驗證後修正文件
- T7（`.regular` 覆蓋 `LSUIElement`）請確認是不是刻意的：目前 `applicationDidBecomeActive` 靠 Dock 圖示來重新開啟視窗，改掉可能影響這個行為

---

## 附錄：資料來源

- LaunchOS：[GitHub](https://github.com/Remix-Design/LaunchOS)、[官網](https://launchosapp.com)、[release notes](https://launchosapp.com/release.en)、`brew info --cask launchos`
- 比較文（都出自競品，僅供參考）：[DrBuho](https://www.drbuho.com/review/launchos-alternative)、[LaunchMe](https://launchmeapp.com/blog/launchme-vs-launchos.html)、[AppGrid](https://appgridmac.com/best-app-launchers-for-macos-tahoe/)
- 開源專案：§3.1 表格內連結；LaunchNext、Launchy 等是 shallow clone 下來讀原始碼
- 本機驗證：原生 Launchpad DB 用 `sqlite3 -readonly` 查詢；你的 repo 用 `gh api`、`gh release view`、`curl -I` 查詢
