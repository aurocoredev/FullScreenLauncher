# 簽章與公證 Runbook

目標：讓使用者下載後直接雙擊就能開啟，不必右鍵「打開」，也不會看到「無法驗證開發者」。

- Team ID：`TMW5T9TWGW`
- Bundle ID：`com.custom.fullscreenlauncher` ← **不要改**，所有使用者設定（分類、手動指派、快捷鍵）都綁在這個 ID 上

---

## 0. 先搞清楚你缺什麼

```bash
security find-identity -v -p codesigning
```

目前機器上有的是：

| 憑證 | 用途 | 能不能簽對外下載的 app |
|---|---|---|
| `Apple Development` | 開發、在自己機器上跑 | ✗ |
| `Apple Distribution` | 上架 Mac App Store | ✗ |
| **`Developer ID Application`** | **對外直接下載** | ✓ ← 你缺這張 |

所以第一步是去申請 Developer ID Application 憑證。年費你已經付了（Apple Developer Program $99/年），這張憑證不用另外付錢。

---

## 1. 申請 Developer ID Application 憑證（只做一次）

**方法一：Xcode（最省事）**

1. Xcode → Settings → Accounts
2. 選你的 Apple ID → 選 Team（`TMW5T9TWGW`）
3. 右下角 **Manage Certificates…**
4. 左下角 **+** → 選 **Developer ID Application**
5. 完成後憑證會自動裝進 login keychain

**方法二：開發者網站**

1. Keychain Access → 選單列 Keychain Access → Certificate Assistant → **Request a Certificate From a Certificate Authority**
   - Email 填你的 Apple ID，Common Name 隨意
   - 選 **Saved to disk**，會產生 `CertificateSigningRequest.certSigningRequest`
2. 到 [developer.apple.com/account/resources/certificates](https://developer.apple.com/account/resources/certificates) → **+**
3. 選 **Developer ID Application** → 上傳剛才的 CSR
4. 下載 `.cer` 並雙擊安裝

> **權限注意**：只有 Account Holder 能建立 Developer ID 憑證（Admin 在 Account Holder 同意後也可以）。如果團隊帳號不是你本人持有，要找持有者操作。

裝好後再確認一次，應該會多出一行：

```bash
security find-identity -v -p codesigning | grep "Developer ID Application"
# → "Developer ID Application: ... (TMW5T9TWGW)"
```

---

## 2. 建立公證用的憑證（只做一次）

公證要用 App 專用密碼，不是你的 Apple ID 密碼。

1. 到 [appleid.apple.com](https://appleid.apple.com) → 登入 → **Sign-In and Security** → **App-Specific Passwords** → 產生一組，格式像 `abcd-efgh-ijkl-mnop`
2. 存進 keychain，之後就不用再輸入：

```bash
xcrun notarytool store-credentials "FSL_NOTARY" \
    --apple-id "tbenking2009@gmail.com" \
    --team-id "TMW5T9TWGW" \
    --password "abcd-efgh-ijkl-mnop"
```

`FSL_NOTARY` 是你自己取的名字，後面每次公證都用它。

---

## 3. 每次發版要做的事

### 3.1 建置並簽章

```bash
export SIGN_IDENTITY="Developer ID Application: 你的名字 (TMW5T9TWGW)"
./build.sh
```

`build.sh` 看到 `SIGN_IDENTITY` 就會自動簽章並驗證。它用的參數是：

```bash
codesign --force --timestamp --options runtime --sign "$SIGN_IDENTITY" FullScreenLauncher.app
```

- `--options runtime`：啟用 Hardened Runtime，**公證的必要條件**
- `--timestamp`：加上安全時間戳，同樣是必要條件
- 這個 app 沒有內嵌框架或 helper，所以不需要 `--deep`，也不需要 entitlements 檔

### 3.2 打包送公證

```bash
ditto -c -k --sequesterRsrc --keepParent FullScreenLauncher.app FullScreenLauncher.app.zip

xcrun notarytool submit FullScreenLauncher.app.zip \
    --keychain-profile "FSL_NOTARY" --wait
```

`--wait` 會等到結果出來，通常 1～5 分鐘。看到 `status: Accepted` 就過了。

被退件的話，用回傳的 submission id 看原因：

```bash
xcrun notarytool log <submission-id> --keychain-profile "FSL_NOTARY"
```

### 3.3 釘上票證並重新打包

```bash
xcrun stapler staple FullScreenLauncher.app
ditto -c -k --sequesterRsrc --keepParent FullScreenLauncher.app FullScreenLauncher.app.zip
```

**順序很重要**：釘的是 `.app`，不是 zip；釘完之後要**重新打包**，否則你上傳的還是沒有票證的舊 zip。釘上票證後，使用者即使離線也能通過驗證。

### 3.4 驗證（用使用者的角度）

```bash
spctl -a -vvv -t install FullScreenLauncher.app
# 期望：accepted / source=Notarized Developer ID

xcrun stapler validate FullScreenLauncher.app
# 期望：The validate action worked!

codesign -dv --verbose=4 FullScreenLauncher.app 2>&1 | grep -E "Identifier|Authority|TeamIdentifier|Runtime"
# 期望：Identifier=com.custom.fullscreenlauncher
#       Authority=Developer ID Application: ...
#       TeamIdentifier=TMW5T9TWGW
#       runtime 旗標存在（Hardened Runtime 已啟用）
```

> 未簽章時 `Identifier` 會是 `FullScreenLauncher-arm64`（連結器給的臨時簽章），
> 正式簽章後會換成 Info.plist 裡的 Bundle ID。

更接近真實情況的測試：把 zip 丟到另一台機器，或手動加上隔離屬性再開一次。

```bash
xattr -w com.apple.quarantine "0081;00000000;Safari;" /tmp/FullScreenLauncher.app
open /tmp/FullScreenLauncher.app
```

### 3.5 發佈

```bash
gh release create v1.4.0 FullScreenLauncher.app.zip \
    --repo aurocoredev/FullScreenLauncher \
    --title "v1.4.0" --notes "..."
```

---

## 4. 常見問題

**「為什麼不能用 Apple Distribution 憑證？」**
那張是給 Mac App Store 的，Gatekeeper 不接受它簽的直接下載檔案。兩者用途完全分開。

**「公證會不會看到我的原始碼？」**
不會。Apple 跑的是自動化惡意軟體掃描，不是人工審查，也沒有 App Store 那套審查標準。

**「每次發版都要重做嗎？」**
憑證與 keychain profile 只設定一次；簽章、公證、釘票證每次發版都要做。

**「以後加了輔助使用或螢幕錄製功能怎麼辦？」**
Hardened Runtime 下有些能力要額外的 entitlements。目前用的 Carbon 全域快捷鍵不需要。真的要加的話，寫一份 `.entitlements` 並在簽章時用 `--entitlements` 指定。

**「Bundle ID 可以順便整理成 `com.aurocore.*` 嗎？」**
技術上可以，Developer ID 不像 App Store 會檢查唯一性。但改了之後使用者的設定會全部歸零（分類、手動指派、快捷鍵都讀不到），除非另外寫搬移邏輯。不建議。

---

## 5. 公證完成後要改的東西

README 的安裝步驟目前寫著「右鍵點擊 → 選擇打開（因為沒有 Apple 開發者簽名）」，公證後這段可以刪掉，改成直接拖到「應用程式」就好。中英文兩段都要改。
