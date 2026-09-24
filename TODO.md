# TODO

> 依優先序。詳細背景見 `docs/reviews/` 兩份報告。

## 手測未完成（下次開啟 app 時順手做）

- [ ] 刪除分類的確認對話框外觀與文案
- [ ] 分類管理列的操作按鈕 hover 才出現，確認不會太隱晦
- [ ] 方向鍵 + `⏎` 在實際使用中的手感（目前只有 harness 驗證邏輯）

## P0 — 效能債（競品都在主打速度）

- [ ] **T1 開啟時不要同步重掃**（`showWindow()` → `refresh()`）
  - 陷阱：不能直接刪掉。`DirectoryMonitor` 只監聽頂層目錄，但掃描含下一層子目錄，在既有子目錄裡新增 App 不會觸發
  - 兩個選項：改用遞迴 FSEvents stream，或保留重新驗證但移到背景 queue 並以 path 做 diff
- [ ] **T2 `AppItem.id` 改用 path**，目前每次掃描都產生新 UUID，SwiftUI 視為全新清單
- [ ] **T3 分類結果快取**
  - 陷阱：手動指派、分類新增/編輯/刪除、重設都會影響結果
  - 建議只快取昂貴的部分（每個 path 的「自動分類 key」），手動指派與 `findCategory` 查詢時即時合成
- [ ] 量測實際延遲，別只靠推論

## P1 — 放大自動分類這個差異化

- [ ] **匯入原生 Launchpad 資料夾轉成分類**：本機 DB 仍在（`$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`），6 個資料夾可一鍵轉入。用系統內建 SQLite3，schema 參考 lporg（MIT）
- [ ] 右鍵選單：在 Finder 顯示、複製路徑、**移到分類…**、隱藏
- [ ] 首頁「常用 / 最近」一列（`NSWorkspace.didLaunchApplicationNotification` 計數）
- [ ] 拼音 / 縮寫搜尋（`applyingTransform(.toLatin)`）與結果排序
- [ ] 分類設定 JSON 匯出 / 匯入
- [ ] 開機自動啟動：`SMAppService.mainApp`（macOS 13+），12 保留文字說明

## P2 — 有餘力再做

- [ ] 公證：產生 App 專用密碼 → `notarytool store-credentials` → 發 v1.3.1（流程見 `docs/release-signing.md`）
- [ ] 熱角（Launchy 是 MIT 可參考，需 1 秒冷卻）
- [ ] 隱藏 App、自訂掃描目錄
- [ ] 資料夾內拖曳排序
- [ ] Homebrew tap
- [ ] V2 卡片依 App 數量或使用頻率分級（要先有使用頻率資料，見 P1）

## 小瑕疵

- [ ] `openCount` 一次啟用會 +2（`applicationShouldHandleReopen` 與 `applicationDidBecomeActive` 都呼叫 `showWindow`），只影響提示何時消失
- [ ] `setActivationPolicy(.regular)` 覆蓋 Info.plist 的 `LSUIElement`，實際會有 Dock 圖示。確認是刻意的，或改掉（改掉會影響從 Dock 重新開啟的行為）
- [ ] `autoCategorizePapp()` 函式名有 typo（多一個大寫 P）
- [ ] 發佈前驗證矩陣：macOS 12 / 15 / 26 × Apple Silicon / Intel
