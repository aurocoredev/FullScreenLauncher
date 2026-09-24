# PROJECT_STATE

> 最後更新：2026-09-24

## 現況

| 項目 | 狀態 |
|---|---|
| 版本 | **v1.3.0** 已發佈（2026-09-24），下載連結實測正常 |
| 程式碼 | 單檔 `main.swift` 約 2,640 行，無外部依賴 |
| 建置 | `./build.sh` 產出 universal binary（arm64 + x86_64），最低 macOS 12，版本號讀自 Info.plist |
| 簽章 | 憑證已備妥（`Developer ID Application: benjing Tao (TMW5T9TWGW)`，到期 2027-02-01），`build.sh` 設 `SIGN_IDENTITY` 即簽章 |
| 公證 | **尚未進行**，缺 App 專用密碼與 `notarytool store-credentials` |
| 發佈頁 | repo description 與 10 個 topics 已補；截圖已更新為 v1.3.0 介面 |
| 手測 | 快捷鍵錄製、⌘/ 開關已由使用者確認；確認對話框與 hover 操作尚未實機測過 |

## 這次做了什麼（2026-09-24，11 個 commit）

1. **相容性**：程式碼有 12 處 macOS 14/15 API 沒加版本保護，且建置產物實際是 macOS 26 專用、僅 arm64 —— 與 README 宣稱不符。加了 `compat*` 包裝，build.sh 改讀 Info.plist 的最低版本並產出 universal binary
2. **持久化與互動修正**：刪除的預設分類會復活、分類管理重複掃描、ESC 不理會面板、快捷鍵註冊失敗沒有復原
3. **快捷鍵驗證**：錄製階段擋掉系統快捷鍵（比對 `CopySymbolicHotKeys`）與無修飾鍵組合
4. **UI 改版**：介面收斂為中性灰階、鍵盤導航、在地化名稱、空狀態、搜尋顯示分類、刪除確認等（P0/P1 全數、P2 七項）
5. **發佈**：v1.3.0 release、repo 曝光設定、簽章準備、安裝說明修正

## 關鍵決策（附理由，不要輕易推翻）

- **介面只用中性灰階**：畫面主體是幾十個彩色 App 圖示，介面再用彩色就是互搶。彩色只留給圖示與 danger
- **快捷鍵維持非 exclusive 註冊**：改成 exclusive 只能偵測同樣用 exclusive 的第三方 app，卻會讓啟動時的衝突變成「註冊失敗」而非共存
- **Bundle ID 維持 `com.custom.fullscreenlauncher`**：所有使用者設定綁在上面，改了會全部歸零
- **維持 FullScreenLauncher 這個名字**：`FullLauncher` 英文語意不通，也會丟掉搜尋關鍵字
- **不做 Launchpad 式分頁與自由拖曳資料夾**：與自動分類模型衝突，且是 LaunchNext issue 最多的區域
- **自動分類是護城河**：競品（LaunchOS、LaunchNext、Launchie）都沒做，所有新功能應該優先強化它

## 已驗證 / 未驗證

**已驗證**
- macOS 12 目標（arm64 與 x86_64）型別檢查 0 error、0 warning
- harness 測試：分類 migration 10 項、快捷鍵 14 項、ESC 分層 7 項、鍵盤導航 11 項
- GUI：ESC 關閉三種 sheet、快捷鍵衝突保留舊設定、刪除分類後重啟、數量即時更新
- 發佈的 zip 下載回來確認是 universal、`minos 12.0`、版本 1.3.0

**未驗證**
- 實機 macOS 12–15 或 Intel（發佈前應建立驗證矩陣）
- 確認對話框、hover 才出現的分類操作按鈕（需滑鼠實機操作）
- 效能沒有量測過，T1–T3 的實際延遲只有推論

## 文件地圖

| 檔案 | 內容 |
|---|---|
| `docs/reviews/competitor-analysis-20260911.md` | 與 LaunchOS 及開源競品的比較、技術債清單、借鏡優先序 |
| `docs/reviews/uiux-audit-20260924.md` | UI/UX 盤點與設計 token 提案，含實作狀態 |
| `docs/release-signing.md` | 簽章與公證 runbook |
| `TODO.md` | 待辦，依優先序 |
