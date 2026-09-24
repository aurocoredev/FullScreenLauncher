import Cocoa
import SwiftUI
import Carbon.HIToolbox

// MARK: - Language Support
enum AppLanguage: String, CaseIterable {
    case chinese = "zh-TW"
    case english = "en"

    var displayName: String {
        switch self {
        case .chinese: return "繁體中文"
        case .english: return "English"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }

    private let strings: [AppLanguage: [String: String]] = [
        .chinese: [
            // Launch Behavior
            "closeAfterLaunch": "啟動後關閉",
            "stayOpen": "保持開啟",

            // Default Categories
            "cat.productivity": "生產力工具",
            "cat.development": "開發工具",
            "cat.media": "影音媒體",
            "cat.utilities": "系統工具",
            "cat.social": "社交通訊",
            "cat.games": "遊戲",
            "cat.design": "創意設計",
            "cat.education": "教育學習",
            "cat.browsers": "瀏覽器",
            "cat.other": "其他",

            // Settings
            "settings": "設定",
            "iconSize": "圖標大小",
            "gridSpacing": "間距",
            "backgroundDepth": "背景深度",
            "showCategories": "顯示分類",
            "groupByCategory": "依類別分組顯示應用程式",
            "launchBehavior": "啟動行為",
            "globalHotkey": "全域快捷鍵",
            "language": "語言",
            "cancel": "取消",
            "modify": "修改",
            "hotkeyInUse": "此快捷鍵已被佔用，已保留原本的快捷鍵",
            "hotkeyNeedsModifier": "請至少加上一個修飾鍵（⌘ ⌥ ⌃ ⇧），或直接使用 F1–F20",
            "hotkeySystemReserved": "這是 macOS 系統快捷鍵，按下時不會傳給啟動器",
            "hotkeyRecordingHint": "按下新的組合鍵，或按 ESC 取消",
            "hotkeyRecordingTimeout": "沒有收到按鍵，已結束錄製",
            "resetSettings": "恢復預設設定",
            "resetSettingsConfirm": "恢復預設設定？",
            "resetSettingsMessage": "圖標大小、間距、背景深度、啟動行為與快捷鍵都會回到預設值。",
            "reset": "恢復預設",
            "close": "關閉",
            "delete": "刪除",
            "deleteCategoryConfirm": "刪除「%@」？",
            "deleteCategoryMessage": "這個分類裡的 %d 個應用程式會回到自動分類。這個動作無法復原。",
            "resetCategoriesConfirm": "重置為預設分類？",
            "resetCategoriesMessage": "自訂分類會被移除，%d 個手動指派也會一併清除。這個動作無法復原。",
            "noResults": "找不到「%@」",
            "noResultsHint": "換個關鍵字，或按 ESC 清除",
            "emptyCategory": "這個分類還沒有應用程式",
            "emptyCategoryHint": "到分類管理指派應用程式",
            "noApps": "沒有掃描到應用程式",
            "noAppsHint": "按右上角重新掃描",
            "refresh": "重新掃描",
            "clearSearch": "清除",
            "inCategory": "在「%@」裡",
            "hotkeyRegisterFailed": "無法註冊此快捷鍵（錯誤碼 %d），已保留原本的快捷鍵",
            "save": "儲存",
            "add": "新增",
            "done": "完成",

            // Category Manager
            "categoryManager": "分類管理",
            "addCategory": "新增分類",
            "editCategory": "編輯分類",
            "resetToDefaults": "重置為預設分類",
            "selectIcon": "選擇圖標",
            "categoryName": "分類名稱",
            "manageApps": "管理應用程式",
            "deleteCategory": "刪除分類",
            "appsCount": "%d 個應用程式",
            "appsWillBeCategorized": "勾選的應用程式會歸類到「%@」",

            // Main UI
            "searchApps": "搜尋應用程式...",
            "searchCategoryOrApps": "搜尋分類或應用程式...",
            "searchThisCategory": "搜尋此分類...",
            "back": "返回",
            "all": "全部",

            // Hints
            "hintKeyboard": "↑ ↓ ← → 選擇，⏎ 開啟，ESC 關閉",
            "hintHotkey": "快捷鍵",

            // Menu
            "openLauncher": "開啟啟動器",
            "quit": "結束"
        ],
        .english: [
            // Launch Behavior
            "closeAfterLaunch": "Close after launch",
            "stayOpen": "Stay open",

            // Default Categories
            "cat.productivity": "Productivity",
            "cat.development": "Development",
            "cat.media": "Media",
            "cat.utilities": "Utilities",
            "cat.social": "Social",
            "cat.games": "Games",
            "cat.design": "Design",
            "cat.education": "Education",
            "cat.browsers": "Browsers",
            "cat.other": "Other",

            // Settings
            "settings": "Settings",
            "iconSize": "Icon Size",
            "gridSpacing": "Spacing",
            "backgroundDepth": "Background Depth",
            "showCategories": "Show Categories",
            "groupByCategory": "Group applications by category",
            "launchBehavior": "Launch Behavior",
            "globalHotkey": "Global Hotkey",
            "language": "Language",
            "cancel": "Cancel",
            "modify": "Modify",
            "hotkeyInUse": "This shortcut is already in use. Kept the previous one.",
            "hotkeyNeedsModifier": "Add at least one modifier (⌘ ⌥ ⌃ ⇧), or use F1–F20.",
            "hotkeySystemReserved": "This is a macOS system shortcut and won't reach the launcher.",
            "hotkeyRecordingHint": "Press a new combination, or press ESC to cancel",
            "hotkeyRecordingTimeout": "No key detected. Recording stopped.",
            "resetSettings": "Reset settings",
            "resetSettingsConfirm": "Reset settings?",
            "resetSettingsMessage": "Icon size, spacing, background depth, launch behavior and the shortcut all return to their defaults.",
            "reset": "Reset",
            "close": "Close",
            "delete": "Delete",
            "deleteCategoryConfirm": "Delete \"%@\"?",
            "deleteCategoryMessage": "The %d apps in this category go back to automatic sorting. This can't be undone.",
            "resetCategoriesConfirm": "Reset to default categories?",
            "resetCategoriesMessage": "Custom categories are removed, along with %d manual assignments. This can't be undone.",
            "noResults": "No apps match \"%@\"",
            "noResultsHint": "Try another search, or press ESC to clear",
            "emptyCategory": "No apps in this category yet",
            "emptyCategoryHint": "Assign apps in the category manager",
            "noApps": "No apps found",
            "noAppsHint": "Rescan from the top right",
            "refresh": "Rescan",
            "clearSearch": "Clear",
            "inCategory": "in %@",
            "hotkeyRegisterFailed": "Couldn't register this shortcut (error %d). Kept the previous one.",
            "save": "Save",
            "add": "Add",
            "done": "Done",

            // Category Manager
            "categoryManager": "Category Manager",
            "addCategory": "Add Category",
            "editCategory": "Edit Category",
            "resetToDefaults": "Reset to Defaults",
            "selectIcon": "Select Icon",
            "categoryName": "Category Name",
            "manageApps": "Manage Apps",
            "deleteCategory": "Delete Category",
            "appsCount": "%d apps",
            "appsWillBeCategorized": "Selected apps will be added to \"%@\"",

            // Main UI
            "searchApps": "Search apps...",
            "searchCategoryOrApps": "Search categories or apps...",
            "searchThisCategory": "Search this category...",
            "back": "Back",
            "all": "All",

            // Hints
            "hintKeyboard": "Arrow keys to select, Return to open, ESC to close",
            "hintHotkey": "Hotkey",

            // Menu
            "openLauncher": "Open Launcher",
            "quit": "Quit"
        ]
    ]

    init() {
        if let saved = UserDefaults.standard.string(forKey: "appLanguage"),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            self.currentLanguage = .chinese
        }
    }

    func localized(_ key: String) -> String {
        strings[currentLanguage]?[key] ?? key
    }

    func localized(_ key: String, _ args: CVarArg...) -> String {
        let format = strings[currentLanguage]?[key] ?? key
        return String(format: format, arguments: args)
    }

    // 取得分類的顯示名稱（支援動態翻譯）
    func categoryDisplayName(_ category: CustomCategory) -> String {
        if let key = category.categoryKey {
            return localized("cat.\(key)")
        }
        return category.name
    }
}

// 簡化存取的全域函式
func L(_ key: String) -> String {
    LocalizationManager.shared.localized(key)
}

func L(_ key: String, _ args: CVarArg...) -> String {
    let format = LocalizationManager.shared.localized(key)
    return String(format: format, arguments: args)
}

// MARK: - Launch Behavior
enum LaunchBehavior: String, CaseIterable {
    case closeAfterLaunch = "closeAfterLaunch"
    case stayOpen = "stayOpen"

    var displayName: String {
        L(self.rawValue)
    }
}

// MARK: - Settings Model
class LauncherSettings: ObservableObject {
    static let shared = LauncherSettings()

    @Published var iconSize: CGFloat {
        didSet { UserDefaults.standard.set(iconSize, forKey: "iconSize") }
    }
    @Published var gridSpacing: CGFloat {
        didSet { UserDefaults.standard.set(gridSpacing, forKey: "gridSpacing") }
    }
    @Published var showCategories: Bool {
        didSet { UserDefaults.standard.set(showCategories, forKey: "showCategories") }
    }
    @Published var backgroundOpacity: Double {
        didSet { UserDefaults.standard.set(backgroundOpacity, forKey: "backgroundOpacity") }
    }
    @Published var hotkeyKeyCode: UInt32 {
        didSet { UserDefaults.standard.set(hotkeyKeyCode, forKey: "hotkeyKeyCode") }
    }
    @Published var hotkeyModifiers: UInt32 {
        didSet { UserDefaults.standard.set(hotkeyModifiers, forKey: "hotkeyModifiers") }
    }
    @Published var launchBehavior: LaunchBehavior {
        didSet { UserDefaults.standard.set(launchBehavior.rawValue, forKey: "launchBehavior") }
    }
    /// 開啟次數，用來決定是否還要顯示操作提示
    @Published var openCount: Int {
        didSet { UserDefaults.standard.set(openCount, forKey: "openCount") }
    }

    init() {
        self.iconSize = UserDefaults.standard.object(forKey: "iconSize") as? CGFloat ?? 64
        self.gridSpacing = UserDefaults.standard.object(forKey: "gridSpacing") as? CGFloat ?? 25
        self.showCategories = UserDefaults.standard.object(forKey: "showCategories") as? Bool ?? true
        self.backgroundOpacity = UserDefaults.standard.object(forKey: "backgroundOpacity") as? Double ?? 0.6
        self.hotkeyKeyCode = UserDefaults.standard.object(forKey: "hotkeyKeyCode") as? UInt32 ?? 0x7A  // F1
        self.hotkeyModifiers = UserDefaults.standard.object(forKey: "hotkeyModifiers") as? UInt32 ?? UInt32(cmdKey | optionKey)
        self.openCount = UserDefaults.standard.integer(forKey: "openCount")

        if let behaviorString = UserDefaults.standard.string(forKey: "launchBehavior"),
           let behavior = LaunchBehavior(rawValue: behaviorString) {
            self.launchBehavior = behavior
        } else {
            self.launchBehavior = .closeAfterLaunch
        }
    }

    func resetToDefaults() {
        iconSize = 64
        gridSpacing = 25
        showCategories = true
        backgroundOpacity = 0.6
        launchBehavior = .closeAfterLaunch
        hotkeyKeyCode = 0x7A   // F1
        hotkeyModifiers = UInt32(cmdKey | optionKey)
        HotkeyManager.shared.registerHotkey()
    }

    var hotkeyDescription: String {
        var parts: [String] = []
        if hotkeyModifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        if hotkeyModifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if hotkeyModifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if hotkeyModifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        parts.append(keyCodeToString(hotkeyKeyCode))
        return parts.joined(separator: "")
    }

    func keyCodeToString(_ keyCode: UInt32) -> String {
        let keyMap: [UInt32: String] = [
            // Function keys
            0x7A: "F1", 0x78: "F2", 0x63: "F3", 0x76: "F4",
            0x60: "F5", 0x61: "F6", 0x62: "F7", 0x64: "F8",
            0x65: "F9", 0x6D: "F10", 0x67: "F11", 0x6F: "F12",
            0x69: "F13", 0x6B: "F14", 0x71: "F15", 0x6A: "F16",
            0x40: "F17", 0x4F: "F18", 0x50: "F19", 0x5A: "F20",

            // Letters A-Z
            0x00: "A", 0x0B: "B", 0x08: "C", 0x02: "D", 0x0E: "E",
            0x03: "F", 0x05: "G", 0x04: "H", 0x22: "I", 0x26: "J",
            0x28: "K", 0x25: "L", 0x2E: "M", 0x2D: "N", 0x1F: "O",
            0x23: "P", 0x0C: "Q", 0x0F: "R", 0x01: "S", 0x11: "T",
            0x20: "U", 0x09: "V", 0x0D: "W", 0x07: "X", 0x10: "Y",
            0x06: "Z",

            // Numbers 0-9
            0x1D: "0", 0x12: "1", 0x13: "2", 0x14: "3", 0x15: "4",
            0x17: "5", 0x16: "6", 0x1A: "7", 0x1C: "8", 0x19: "9",

            // Special keys
            0x31: "Space", 0x24: "Return", 0x30: "Tab", 0x33: "Delete",
            0x35: "Esc", 0x7B: "←", 0x7C: "→", 0x7D: "↓", 0x7E: "↑",
            0x73: "Home", 0x77: "End", 0x74: "PageUp", 0x79: "PageDown",

            // Punctuation
            0x27: "'", 0x2A: "\\", 0x2B: ",", 0x2C: "/", 0x2F: ".",
            0x29: ";", 0x18: "=", 0x21: "[", 0x1E: "]", 0x1B: "-",
            0x32: "`",

            // Numpad
            0x52: "Num0", 0x53: "Num1", 0x54: "Num2", 0x55: "Num3",
            0x56: "Num4", 0x57: "Num5", 0x58: "Num6", 0x59: "Num7",
            0x5B: "Num8", 0x5C: "Num9", 0x43: "Num*", 0x45: "Num+",
            0x4B: "Num/", 0x4E: "Num-", 0x41: "Num.", 0x4C: "NumEnter"
        ]
        return keyMap[keyCode] ?? "Key\(keyCode)"
    }
}

// MARK: - Custom Category Model
struct CustomCategory: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var appPaths: [String]  // 儲存應用程式路徑
    var categoryKey: String?  // 預設分類的 key（如 "productivity"）

    // 顯示名稱（動態翻譯）
    var displayName: String {
        LocalizationManager.shared.categoryDisplayName(self)
    }

    init(id: UUID = UUID(), name: String, icon: String = "folder.fill",
         appPaths: [String] = [], categoryKey: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.appPaths = appPaths
        self.categoryKey = categoryKey
    }
}

// MARK: - Category Manager
class CategoryManager: ObservableObject {
    static let shared = CategoryManager()

    @Published var categories: [CustomCategory] = []

    private let defaultCategories: [CustomCategory] = [
        CustomCategory(name: "生產力工具", icon: "briefcase.fill", categoryKey: "productivity"),
        CustomCategory(name: "開發工具", icon: "hammer.fill", categoryKey: "development"),
        CustomCategory(name: "影音媒體", icon: "play.circle.fill", categoryKey: "media"),
        CustomCategory(name: "系統工具", icon: "gearshape.2.fill", categoryKey: "utilities"),
        CustomCategory(name: "社交通訊", icon: "message.fill", categoryKey: "social"),
        CustomCategory(name: "遊戲", icon: "gamecontroller.fill", categoryKey: "games"),
        CustomCategory(name: "創意設計", icon: "paintbrush.fill", categoryKey: "design"),
        CustomCategory(name: "教育學習", icon: "book.fill", categoryKey: "education"),
        CustomCategory(name: "瀏覽器", icon: "globe", categoryKey: "browsers"),
        CustomCategory(name: "其他", icon: "square.grid.2x2.fill", categoryKey: "other")
    ]

    private let saveKey = "customCategories"
    private let appCategoryMapKey = "appCategoryMap"
    private let seenDefaultKeysKey = "seenDefaultCategoryKeys"

    // eeaa720 新增 design/education/browsers 之前就存在的預設分類；
    // 舊使用者沒有 seen 紀錄時視為已見過，避免把他們刪掉的分類補回來
    private let legacyDefaultKeys: Set<String> = [
        "productivity", "development", "media", "utilities", "social", "games", "other"
    ]

    // 「其他」是自動分類的最終落點，不可刪除
    static let fallbackCategoryKey = "other"

    // 應用程式路徑 -> 分類ID 的映射
    @Published var appCategoryMap: [String: UUID] = [:]

    init() {
        loadCategories()
        loadAppCategoryMap()
        migrateCategoriesToAddCategoryKey()
        migrateAddNewDefaultCategories()
    }

    func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([CustomCategory].self, from: data) {
            categories = decoded
        } else {
            categories = defaultCategories
            saveCategories()
        }
    }

    // 遷移舊版分類：根據名稱加入 categoryKey
    private func migrateCategoriesToAddCategoryKey() {
        let nameToKeyMap: [String: String] = [
            "生產力工具": "productivity",
            "開發工具": "development",
            "影音媒體": "media",
            "系統工具": "utilities",
            "社交通訊": "social",
            "遊戲": "games",
            "創意設計": "design",
            "教育學習": "education",
            "瀏覽器": "browsers",
            "其他": "other"
        ]

        var needsSave = false
        for i in categories.indices {
            if categories[i].categoryKey == nil,
               let key = nameToKeyMap[categories[i].name] {
                categories[i].categoryKey = key
                needsSave = true
            }
        }

        if needsSave {
            saveCategories()
        }
    }

    // 遷移：只補使用者「從未見過」的新預設分類；使用者主動刪除的不會復活
    private func migrateAddNewDefaultCategories() {
        let defaults = UserDefaults.standard
        let seenKeys = defaults.stringArray(forKey: seenDefaultKeysKey).map(Set.init) ?? legacyDefaultKeys
        let existingKeys = Set(categories.compactMap { $0.categoryKey })
        let newDefaults = defaultCategories.filter {
            guard let key = $0.categoryKey else { return false }
            return !seenKeys.contains(key) && !existingKeys.contains(key)
        }
        let allDefaultKeys = defaultCategories.compactMap { $0.categoryKey }
        defaults.set(Array(seenKeys.union(allDefaultKeys)), forKey: seenDefaultKeysKey)

        guard !newDefaults.isEmpty else { return }

        // 插入到「其他」之前
        if let otherIndex = categories.firstIndex(where: { $0.categoryKey == "other" }) {
            for (offset, cat) in newDefaults.enumerated() {
                categories.insert(cat, at: otherIndex + offset)
            }
        } else {
            categories.append(contentsOf: newDefaults)
        }
        saveCategories()
    }

    func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func loadAppCategoryMap() {
        if let data = UserDefaults.standard.data(forKey: appCategoryMapKey),
           let decoded = try? JSONDecoder().decode([String: UUID].self, from: data) {
            appCategoryMap = decoded
        }
    }

    func saveAppCategoryMap() {
        if let encoded = try? JSONEncoder().encode(appCategoryMap) {
            UserDefaults.standard.set(encoded, forKey: appCategoryMapKey)
        }
    }

    func addCategory(name: String, icon: String = "folder.fill") {
        let newCategory = CustomCategory(name: name, icon: icon)
        categories.append(newCategory)
        saveCategories()
    }

    func updateCategory(_ category: CustomCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }

    func deleteCategory(_ category: CustomCategory) {
        guard category.categoryKey != Self.fallbackCategoryKey else { return }

        // 移除該分類下所有應用的映射
        appCategoryMap = appCategoryMap.filter { $0.value != category.id }
        saveAppCategoryMap()

        categories.removeAll { $0.id == category.id }
        saveCategories()
    }

    func setAppCategory(appPath: String, categoryId: UUID?) {
        if let id = categoryId {
            appCategoryMap[appPath] = id
        } else {
            appCategoryMap.removeValue(forKey: appPath)
        }
        saveAppCategoryMap()
    }

    func getCategoryForApp(appPath: String, appName: String) -> CustomCategory? {
        // 先檢查是否有手動設定的分類
        if let categoryId = appCategoryMap[appPath],
           let category = categories.first(where: { $0.id == categoryId }) {
            return category
        }

        // 否則使用自動分類；比對到的分類已被刪除時退回「其他」，避免 App 從資料夾中消失
        return autoCategorizePapp(appName: appName, path: appPath)
            ?? findCategory(byKey: Self.fallbackCategoryKey)
    }

    private func findCategory(byKey key: String) -> CustomCategory? {
        // 優先用 categoryKey 匹配，回退到名稱匹配
        return categories.first { $0.categoryKey == key }
    }

    private func nativeCategoryForApp(atPath path: String) -> CustomCategory? {
        let plistPath = path + "/Contents/Info.plist"
        guard let plist = NSDictionary(contentsOfFile: plistPath),
              let categoryType = plist["LSApplicationCategoryType"] as? String else {
            return nil
        }

        let mapping: [String: String] = [
            "public.app-category.productivity": "productivity",
            "public.app-category.developer-tools": "development",
            "public.app-category.graphics-design": "design",
            "public.app-category.photography": "design",
            "public.app-category.video": "media",
            "public.app-category.music": "media",
            "public.app-category.entertainment": "media",
            "public.app-category.social-networking": "social",
            "public.app-category.education": "education",
            "public.app-category.reference": "education",
            "public.app-category.books": "education",
            "public.app-category.games": "games",
            "public.app-category.board-games": "games",
            "public.app-category.action-games": "games",
            "public.app-category.adventure-games": "games",
            "public.app-category.arcade-games": "games",
            "public.app-category.card-games": "games",
            "public.app-category.casino-games": "games",
            "public.app-category.puzzle-games": "games",
            "public.app-category.racing-games": "games",
            "public.app-category.role-playing-games": "games",
            "public.app-category.simulation-games": "games",
            "public.app-category.sports-games": "games",
            "public.app-category.strategy-games": "games",
            "public.app-category.trivia-games": "games",
            "public.app-category.word-games": "games",
            "public.app-category.utilities": "utilities",
            "public.app-category.news": "productivity",
            "public.app-category.finance": "productivity",
            "public.app-category.business": "productivity",
            "public.app-category.travel": "productivity",
            "public.app-category.weather": "utilities",
            "public.app-category.healthcare-fitness": "utilities",
            "public.app-category.lifestyle": "other",
            "public.app-category.medical": "other",
            "public.app-category.food-drink": "other",
        ]

        // 直接匹配，或處理格式異常（如 "app-category-type=public.app-category.developer-tools"）
        if let categoryKey = mapping[categoryType] {
            return findCategory(byKey: categoryKey)
        }
        for (key, value) in mapping {
            if categoryType.contains(key) {
                return findCategory(byKey: value)
            }
        }
        return nil
    }

    private func autoCategorizePapp(appName: String, path: String) -> CustomCategory? {
        // 優先：讀取 macOS 原生分類（Info.plist 中的 LSApplicationCategoryType）
        if let nativeCategory = nativeCategoryForApp(atPath: path) {
            return nativeCategory
        }

        // 回退：關鍵字比對
        let name = appName.lowercased()
        let pathLower = path.lowercased()

        // 依優先級排列：越前面的分類優先級越高

        // 1. Browsers（在生產力之前，避免 Safari/Chrome 被歸到生產力）
        let browserKeywords = [
            "safari", "chrome", "firefox", "edge", "brave", "arc", "opera",
            "vivaldi", "tor browser", "orion", "chromium"
        ]
        if browserKeywords.contains(where: { name.contains($0) }) {
            return findCategory(byKey: "browsers")
        }

        // 2. Design（在開發工具之前，避免 Figma 被「code」匹配走）
        let designKeywords = [
            "figma", "sketch", "photoshop", "illustrator", "affinity", "pixelmator",
            "gimp", "inkscape", "canva", "blender", "lightroom", "capture one",
            "acorn", "paintcode", "principle", "framer", "zeplin", "krita",
            "vectornator", "linearity", "colorsnapper", "cinema 4d", "maya",
            "adobe bridge"
        ]
        if designKeywords.contains(where: { name.contains($0) }) {
            return findCategory(byKey: "design")
        }

        // 3. Development
        let devKeywords = [
            "xcode", "code", "terminal", "git", "docker", "sublime",
            "visual studio", "intellij", "android", "pycharm", "webstorm",
            "phpstorm", "rider", "clion", "goland", "datagrip", "rubymine",
            "fleet", "cursor", "nova", "bbedit", "iterm", "warp", "kitty",
            "alacritty", "hyper", "postman", "insomnia", "charles", "proxyman",
            "tableplus", "sequel pro", "dbeaver", "tower", "fork", "sourcetree",
            "dash", "rapidapi", "httpie", "local"
        ]
        if devKeywords.contains(where: { name.contains($0) }) {
            return findCategory(byKey: "development")
        }

        // 4. Media
        let mediaKeywords = [
            "music", "photo", "video", "spotify", "vlc", "imovie",
            "final cut", "garageband", "quicktime", "netflix", "youtube",
            "plex", "infuse", "iina", "mpv", "obs", "screenflow",
            "podcast", "apple tv", "shazam", "audacity", "handbrake",
            "davinci", "resolve", "premiere", "after effects", "logic pro",
            "ableton", "fl studio", "pro tools", "audition", "permute",
            "downie", "movist", "elmedia", "vox", "tidal", "deezer",
            "blackmagic", "fairlight"
        ]
        if mediaKeywords.contains(where: { name.contains($0) }) {
            return findCategory(byKey: "media")
        }

        // 5. Social
        let socialKeywords = [
            "message", "mail", "slack", "discord", "telegram", "whatsapp",
            "zoom", "teams", "facetime", "line", "wechat", "skype",
            "signal", "viber", "lark", "feishu", "dingtalk", "webex",
            "thunderbird", "spark", "airmail", "mimestream", "phone"
        ]
        if socialKeywords.contains(where: { name.contains($0) }) {
            return findCategory(byKey: "social")
        }

        // 6. Education
        let educationKeywords = [
            "dictionary", "books", "classroom", "anki", "duolingo", "rosetta",
            "quizlet", "swift playground", "playground", "translate", "coursera", "udemy"
        ]
        if educationKeywords.contains(where: { name.contains($0) }) {
            return findCategory(byKey: "education")
        }

        // 7. Productivity（已移除 safari/chrome/firefox）
        let productivityKeywords = [
            "word", "excel", "pages", "numbers", "keynote", "notion",
            "notes", "reminder", "calendar", "obsidian", "logseq", "craft",
            "bear", "ulysses", "scrivener", "trello", "asana", "todoist",
            "things", "omnifocus", "evernote", "onenote", "powerpoint",
            "airtable", "linear", "jira", "fantastical", "pdf", "preview",
            "acrobat", "alfred", "raycast", "dropbox", "stocks"
        ]
        if productivityKeywords.contains(where: { name.contains($0) }) {
            return findCategory(byKey: "productivity")
        }

        // 8. Utilities
        let utilityKeywords = [
            "system", "disk", "activity", "console", "finder",
            "setting", "preference", "vpn", "password", "1password",
            "lastpass", "bitwarden", "keychain", "time machine", "screenshot",
            "unarchiver", "keka", "betterzip", "appcleaner", "cleanmymac",
            "istat", "bartender", "magnet", "rectangle", "karabiner",
            "automator", "shortcut", "migration", "calculator", "clock",
            "findmy", "home", "weather", "iphone mirroring", "anydesk",
            "defender", "avira"
        ]
        if pathLower.contains("utilities") || utilityKeywords.contains(where: { name.contains($0) }) {
            return findCategory(byKey: "utilities")
        }

        // 9. Games
        let gameKeywords = [
            "game", "steam", "chess", "epic games", "battle.net", "blizzard",
            "minecraft", "roblox", "gog", "playcover"
        ]
        if gameKeywords.contains(where: { name.contains($0) }) || pathLower.contains("games") {
            return findCategory(byKey: "games")
        }

        // 10. Other — fallback
        return findCategory(byKey: "other")
    }

    func resetToDefaults() {
        categories = defaultCategories
        appCategoryMap = [:]
        saveCategories()
        saveAppCategoryMap()
    }
}

// MARK: - App Model
class AppItem: Identifiable, ObservableObject {
    let id = UUID()
    /// 顯示用的在地化名稱（中文系統下 Calculator.app 會是「計算機」）
    let name: String
    /// 檔名（去掉 .app），分類關鍵字與搜尋都會用到
    let fileName: String
    let path: String
    let icon: NSImage

    var category: CustomCategory? {
        CategoryManager.shared.getCategoryForApp(appPath: path, appName: fileName)
    }

    /// 在地化名稱與英文檔名都能搜到
    func matches(_ query: String) -> Bool {
        name.localizedCaseInsensitiveContains(query) || fileName.localizedCaseInsensitiveContains(query)
    }

    init(name: String, fileName: String, path: String, icon: NSImage) {
        self.name = name
        self.fileName = fileName
        self.path = path
        self.icon = icon
    }
}

// MARK: - App Scanner
class AppScanner {
    static func scanApplications() -> [AppItem] {
        var apps: [AppItem] = []
        let fileManager = FileManager.default

        let appDirectories = [
            "/Applications",
            "/System/Applications",
            "/System/Applications/Utilities",
            NSHomeDirectory() + "/Applications"
        ]

        for directory in appDirectories {
            guard let contents = try? fileManager.contentsOfDirectory(atPath: directory) else { continue }

            for item in contents {
                let fullPath = "\(directory)/\(item)"

                if item.hasSuffix(".app") {
                    apps.append(makeItem(path: fullPath, fileName: item))
                } else if directory == "/Applications" || directory == NSHomeDirectory() + "/Applications" {
                    // 掃描子目錄一層深度（Adobe 等 app 安裝在子目錄中）
                    var isDir: ObjCBool = false
                    if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                        if let subContents = try? fileManager.contentsOfDirectory(atPath: fullPath) {
                            for subItem in subContents where subItem.hasSuffix(".app") {
                                apps.append(makeItem(path: "\(fullPath)/\(subItem)", fileName: subItem))
                            }
                        }
                    }
                }
            }
        }

        return apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private static func makeItem(path: String, fileName: String) -> AppItem {
        let icon = NSWorkspace.shared.icon(forFile: path)
        icon.size = NSSize(width: 128, height: 128)
        let bare = fileName.hasSuffix(".app") ? String(fileName.dropLast(4)) : fileName
        return AppItem(name: localizedName(atPath: path) ?? bare, fileName: bare, path: path, icon: icon)
    }

    /// 依系統語言取得 App 的在地化名稱（「計算機」而不是 Calculator）。
    /// `FileManager.displayName` 不可靠：開啟「顯示所有副檔名」時會帶 .app，也不會在地化，
    /// 名稱實際上放在 App bundle 的 InfoPlist.loctable 或 <lang>.lproj/InfoPlist.strings。
    private static func localizedName(atPath path: String) -> String? {
        let resources = path + "/Contents/Resources"

        if let table = NSDictionary(contentsOfFile: resources + "/InfoPlist.loctable") as? [String: Any] {
            for key in localeKeys {
                if let entry = table[key] as? [String: Any],
                   let name = (entry["CFBundleDisplayName"] ?? entry["CFBundleName"]) as? String,
                   !name.isEmpty {
                    return name
                }
            }
        }

        for key in localeKeys {
            let strings = resources + "/\(key).lproj/InfoPlist.strings"
            if let entry = NSDictionary(contentsOfFile: strings) as? [String: Any],
               let name = (entry["CFBundleDisplayName"] ?? entry["CFBundleName"]) as? String,
               !name.isEmpty {
                return name
            }
        }
        return nil
    }

    /// 系統偏好語言展開成 bundle 內可能出現的各種寫法（zh-Hant-TW → zh_TW、zh-Hant、zh…）
    private static let localeKeys: [String] = {
        var keys: [String] = []
        for identifier in Locale.preferredLanguages {
            let locale = Locale(identifier: identifier)
            let language = locale.languageCode ?? identifier
            let candidates = [
                identifier,
                identifier.replacingOccurrences(of: "-", with: "_"),
                locale.regionCode.map { "\(language)_\($0)" },
                locale.regionCode.map { "\(language)-\($0)" },
                locale.scriptCode.map { "\(language)-\($0)" },
                language
            ]
            for candidate in candidates.compactMap({ $0 }) where !keys.contains(candidate) {
                keys.append(candidate)
            }
        }
        return keys
    }()
}

// MARK: - Folder Group Model
struct FolderGroup: Identifiable {
    let id: UUID
    let title: String
    let icon: String
    let apps: [AppItem]

    var count: Int { apps.count }
    var previewApps: [AppItem] { Array(apps.prefix(4)) }
}

// MARK: - Launcher Route
enum LauncherRoute: Equatable {
    case home
    case folderDetail(folderId: UUID)

    static func == (lhs: LauncherRoute, rhs: LauncherRoute) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home):
            return true
        case (.folderDetail(let lhsId), .folderDetail(let rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
}

// MARK: - ViewModel
class LauncherViewModel: ObservableObject {
    static let shared = LauncherViewModel()

    @Published var apps: [AppItem] = []
    @Published var searchText: String = "" {
        didSet { if searchText != oldValue { selection = 0 } }
    }
    @Published var showSettings: Bool = false
    @Published var showCategoryManager: Bool = false

    // Folder browsing state
    @Published var route: LauncherRoute = .home
    @Published var folderQuery: String = "" {
        didSet { if folderQuery != oldValue { selection = 0 } }
    }

    // 鍵盤導航：目前選取的格子，以及每列幾個（由格線在排版時回報）
    @Published var selection: Int = 0
    @Published var columns: Int = 6

    @ObservedObject var categoryManager = CategoryManager.shared

    var filteredApps: [AppItem] {
        var result = apps

        if !searchText.isEmpty {
            result = result.filter { $0.matches(searchText) }
        }

        return result
    }

    // Folder groups derived from apps
    var folderGroups: [FolderGroup] {
        var grouped: [UUID: [AppItem]] = [:]

        for app in apps {
            if let category = app.category {
                grouped[category.id, default: []].append(app)
            }
        }

        return categoryManager.categories.compactMap { category in
            guard let categoryApps = grouped[category.id], !categoryApps.isEmpty else { return nil }
            return FolderGroup(id: category.id, title: category.displayName, icon: category.icon, apps: categoryApps)
        }
    }

    // Currently active folder
    var activeFolder: FolderGroup? {
        guard case .folderDetail(let folderId) = route else { return nil }
        return folderGroups.first { $0.id == folderId }
    }

    // Apps in the active folder, filtered by folderQuery
    var filteredFolderApps: [AppItem] {
        guard let folder = activeFolder else { return [] }
        if folderQuery.isEmpty {
            return folder.apps
        }
        return folder.apps.filter { $0.matches(folderQuery) }
    }

    init() {
        apps = AppScanner.scanApplications()
    }

    func navigateToFolder(id: UUID) {
        withAnimation(Design.animation(0.2)) {
            route = .folderDetail(folderId: id)
            folderQuery = ""
            selection = 0
        }
    }

    func navigateToHome() {
        withAnimation(Design.animation(0.2)) {
            route = .home
            folderQuery = ""
            selection = 0
        }
    }

    /// 目前畫面上可以被選取的項目數
    var selectableCount: Int {
        guard LauncherSettings.shared.showCategories else { return filteredApps.count }
        switch route {
        case .home: return searchText.isEmpty ? folderGroups.count : filteredApps.count
        case .folderDetail: return filteredFolderApps.count
        }
    }

    func moveSelection(dx: Int, dy: Int) {
        let count = selectableCount
        guard count > 0 else { return }
        let target = selection + dx + dy * max(1, columns)
        selection = min(max(target, 0), count - 1)
    }

    /// 開啟目前選取的項目：首頁是資料夾，其餘是 App
    func activateSelection() {
        let count = selectableCount
        guard count > 0, selection >= 0, selection < count else { return }

        guard LauncherSettings.shared.showCategories else {
            launchApp(filteredApps[selection])
            return
        }
        switch route {
        case .home:
            if searchText.isEmpty {
                navigateToFolder(id: folderGroups[selection].id)
            } else {
                launchApp(filteredApps[selection])
            }
        case .folderDetail:
            launchApp(filteredFolderApps[selection])
        }
    }

    func launchApp(_ app: AppItem) {
        NSWorkspace.shared.open(URL(fileURLWithPath: app.path))
        if LauncherSettings.shared.launchBehavior == .closeAfterLaunch {
            NSApplication.shared.hide(nil)
        }
    }

    func refresh() {
        apps = AppScanner.scanApplications()
        objectWillChange.send()
    }
}

// MARK: - macOS 12 Compatibility
// symbolEffect 需 macOS 14（.rotate 需 15）、雙參數 onChange 需 macOS 14；舊系統略過動畫
extension View {
    @ViewBuilder
    func compatOnChange<V: Equatable>(of value: V, perform action: @escaping () -> Void) -> some View {
        if #available(macOS 14.0, *) {
            onChange(of: value) { action() }
        } else {
            onChange(of: value) { _ in action() }
        }
    }
}

// MARK: - Design Tokens
// 畫面主角是各家 App 的彩色圖示，介面本身一律用中性灰階讓位；
// 彩色只保留語意用途（danger = 刪除）。
enum Design {
    enum Palette {
        static let textPrimary = Color.white.opacity(0.95)
        static let textSecondary = Color.white.opacity(0.55)
        static let textTertiary = Color.white.opacity(0.35)

        static let raised = Color.white.opacity(0.08)
        static let raisedHover = Color.white.opacity(0.14)
        static let stroke = Color.white.opacity(0.12)
        static let selection = Color.white.opacity(0.18)

        static let overlaySurface = Color(red: 0.11, green: 0.11, blue: 0.12)
        static let overlayScrim = Color.black.opacity(0.65)

        static let danger = Color(red: 1.0, green: 0.27, blue: 0.23)
    }

    enum Space {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 40
        static let xxl: CGFloat = 64
    }

    enum Radius {
        static let small: CGFloat = 8
        static let large: CGFloat = 16
    }

    enum Typo {
        static let display = Font.system(size: 24, weight: .semibold)
        static let title = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 13)
        static let bodyMedium = Font.system(size: 13, weight: .medium)
        static let caption = Font.system(size: 11)
        // 數量會變動，用等寬數字避免文字寬度跳動
        static let count = Font.system(size: 11).monospacedDigit()
    }

    /// 系統「減少動態效果」開啟時不播動畫
    static var reduceMotion: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    static func animation(_ duration: Double = 0.15) -> Animation? {
        reduceMotion ? nil : .easeInOut(duration: duration)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var settings = LauncherSettings.shared
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var recorder = HotkeyRecorder.shared
    @Binding var isPresented: Bool

    @State private var confirmReset = false

    var body: some View {
        VStack(spacing: 0) {
            PanelHeader(title: L("settings"), icon: "gearshape") { isPresented = false }

            ScrollView {
                VStack(alignment: .leading, spacing: Design.Space.m) {
                    // 快捷鍵擺第一段：這是最常被找的設定
                    SettingSection(title: L("globalHotkey"), icon: "command") {
                        hotkeyControl
                    }

                    SettingSection(title: L("showCategories"), icon: "folder") {
                        Toggle(L("groupByCategory"), isOn: $settings.showCategories)
                            .toggleStyle(.switch)
                            .tint(Design.Palette.textSecondary)
                            .font(Design.Typo.body)
                            .foregroundColor(Design.Palette.textPrimary)
                    }

                    SettingSection(title: L("launchBehavior"), icon: "arrow.up.forward.app") {
                        Picker("", selection: $settings.launchBehavior) {
                            ForEach(LaunchBehavior.allCases, id: \.self) { behavior in
                                Text(behavior.displayName).tag(behavior)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }

                    SettingSection(title: L("iconSize"), icon: "square.grid.2x2") {
                        sliderRow(value: $settings.iconSize, range: 48...128, step: 8,
                                  label: "\(Int(settings.iconSize))")
                    }

                    SettingSection(title: L("gridSpacing"), icon: "arrow.left.arrow.right") {
                        sliderRow(value: $settings.gridSpacing, range: 10...60, step: 5,
                                  label: "\(Int(settings.gridSpacing))")
                    }

                    SettingSection(title: L("backgroundDepth"), icon: "circle.lefthalf.filled") {
                        sliderRow(value: $settings.backgroundOpacity, range: 0.1...0.9, step: 0.1,
                                  label: "\(Int(settings.backgroundOpacity * 100))%")
                    }

                    SettingSection(title: L("language"), icon: "globe") {
                        Picker("", selection: $localization.currentLanguage) {
                            ForEach(AppLanguage.allCases, id: \.self) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }

                    Button(action: { confirmReset = true }) {
                        Text(L("resetSettings"))
                            .font(Design.Typo.body)
                            .foregroundColor(Design.Palette.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.top, Design.Space.s)
                }
                .padding(.horizontal, Design.Space.l)
                .padding(.vertical, Design.Space.l)
            }
            .frame(maxHeight: 520)
        }
        .panelChrome(width: 500)
        .confirmationDialog(L("resetSettingsConfirm"), isPresented: $confirmReset, titleVisibility: .visible) {
            Button(L("reset"), role: .destructive) { settings.resetToDefaults() }
            Button(L("cancel"), role: .cancel) {}
        } message: {
            Text(L("resetSettingsMessage"))
        }
        .onDisappear {
            // 面板被 ESC / 背景點擊 / 關閉鈕收起時，一併結束錄製，避免下一個按鍵被當成快捷鍵
            recorder.cancel()
        }
    }

    // 整塊可點即進入錄製，不再只有右邊按鈕可按
    private var hotkeyControl: some View {
        VStack(alignment: .leading, spacing: Design.Space.s) {
            Button(action: { recorder.isRecording ? recorder.cancel() : recorder.start() }) {
                HStack {
                    Text(settings.hotkeyDescription)
                        .font(.system(size: 15, weight: .medium).monospacedDigit())
                        .foregroundColor(Design.Palette.textPrimary)
                    Spacer()
                    Text(recorder.isRecording ? L("cancel") : L("modify"))
                        .font(Design.Typo.body)
                        .foregroundColor(Design.Palette.textSecondary)
                }
                .padding(.horizontal, Design.Space.m)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: Design.Radius.small)
                        .fill(Design.Palette.raised)
                        .overlay(
                            RoundedRectangle(cornerRadius: Design.Radius.small)
                                .stroke(recorder.isRecording ? Design.Palette.textPrimary : Design.Palette.stroke,
                                        lineWidth: recorder.isRecording ? 2 : 1)
                        )
                )
            }
            .buttonStyle(.plain)

            if recorder.isRecording {
                Text(L("hotkeyRecordingHint"))
                    .font(Design.Typo.caption)
                    .foregroundColor(Design.Palette.textSecondary)
            } else if let error = recorder.errorMessage {
                Text(error)
                    .font(Design.Typo.caption)
                    .foregroundColor(Design.Palette.danger)
            }
        }
    }

    private func sliderRow(value: Binding<CGFloat>, range: ClosedRange<CGFloat>,
                           step: CGFloat, label: String) -> some View {
        HStack(spacing: Design.Space.m) {
            Text(label)
                .font(Design.Typo.count)
                .foregroundColor(Design.Palette.textSecondary)
                .frame(width: 40, alignment: .leading)
            Slider(value: value, in: range, step: step)
                .tint(Design.Palette.textSecondary)
        }
    }

    private func sliderRow(value: Binding<Double>, range: ClosedRange<Double>,
                           step: Double, label: String) -> some View {
        HStack(spacing: Design.Space.m) {
            Text(label)
                .font(Design.Typo.count)
                .foregroundColor(Design.Palette.textSecondary)
                .frame(width: 40, alignment: .leading)
            Slider(value: value, in: range, step: step)
                .tint(Design.Palette.textSecondary)
        }
    }
}

// MARK: - Panel Building Blocks
struct PanelHeader: View {
    let title: String
    let icon: String
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: Design.Space.s) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Design.Palette.textSecondary)
            Text(title)
                .font(Design.Typo.title)
                .foregroundColor(Design.Palette.textPrimary)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Design.Palette.textSecondary)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Design.Palette.raised))
            }
            .buttonStyle(.plain)
            .help(L("close"))
        }
        .padding(Design.Space.l)
    }
}

struct SettingSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Space.s) {
            HStack(spacing: Design.Space.s) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(Design.Palette.textTertiary)
                    .frame(width: 18)
                Text(title)
                    .font(Design.Typo.bodyMedium)
                    .foregroundColor(Design.Palette.textSecondary)
            }
            content()
        }
        .padding(Design.Space.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Design.Radius.small)
                .fill(Design.Palette.raised)
        )
    }
}

struct IconPicker: View {
    @Binding var selection: String

    static let icons = [
        "folder.fill", "star.fill", "heart.fill", "bookmark.fill",
        "tag.fill", "briefcase.fill", "hammer.fill", "wrench.fill",
        "gamecontroller.fill", "music.note", "photo.fill", "video.fill",
        "message.fill", "envelope.fill", "globe", "book.fill",
        "graduationcap.fill", "paintbrush.fill", "camera.fill", "film.fill"
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(40), spacing: Design.Space.s), count: 5),
                  spacing: Design.Space.s) {
            ForEach(Self.icons, id: \.self) { icon in
                Button(action: { selection = icon }) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(selection == icon ? Design.Palette.textPrimary : Design.Palette.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: Design.Radius.small)
                                .fill(selection == icon ? Design.Palette.selection : Design.Palette.raised)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

extension View {
    /// Sheet 共用外觀，與面板同一套深色語言
    func sheetChrome(width: CGFloat) -> some View {
        frame(width: width)
            .background(Design.Palette.overlaySurface)
            // 系統控制項（Slider / Toggle / Picker）跟著用深色外觀
            .environment(\.colorScheme, .dark)
    }

    /// 面板共用外觀：深色表面 + 細邊框 + 陰影
    func panelChrome(width: CGFloat) -> some View {
        frame(width: width)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.large)
                    .fill(Design.Palette.overlaySurface)
                    .shadow(color: .black.opacity(0.45), radius: 30)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.Radius.large)
                    .stroke(Design.Palette.stroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.large))
            .environment(\.colorScheme, .dark)
    }
}

// MARK: - Category Manager View
struct CategoryManagerView: View {
    @Binding var isPresented: Bool
    @ObservedObject var categoryManager = CategoryManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var viewModel = LauncherViewModel.shared
    @State private var showAddCategory = false
    @State private var editingCategory: CustomCategory? = nil
    @State private var showAppSelector: CustomCategory? = nil
    @State private var pendingDelete: CustomCategory? = nil
    @State private var confirmReset = false

    // 共用已掃描的 App 清單，一次算出各分類數量（分類或指派變動時自動重算）
    private var appCounts: [UUID: Int] {
        var counts: [UUID: Int] = [:]
        for app in viewModel.apps {
            if let id = app.category?.id {
                counts[id, default: 0] += 1
            }
        }
        return counts
    }

    var body: some View {
        let counts = appCounts
        VStack(spacing: 0) {
            PanelHeader(title: L("categoryManager"), icon: "folder.badge.gearshape") { isPresented = false }

            // Category List - 可滾動區域
            ScrollView {
                VStack(spacing: Design.Space.s) {
                    ForEach(categoryManager.categories) { category in
                        CategoryRowView(
                            category: category,
                            appCount: counts[category.id] ?? 0,
                            onEdit: { editingCategory = category },
                            onManageApps: { showAppSelector = category },
                            onDelete: { pendingDelete = category }
                        )
                    }

                    // Add Category Button
                    Button(action: { showAddCategory = true }) {
                        HStack(spacing: Design.Space.s) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .semibold))
                            Text(L("addCategory"))
                                .font(Design.Typo.bodyMedium)
                        }
                        .foregroundColor(Design.Palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(Design.Space.m)
                        .background(
                            RoundedRectangle(cornerRadius: Design.Radius.small)
                                .stroke(Design.Palette.stroke, style: StrokeStyle(lineWidth: 1, dash: [6]))
                        )
                    }
                    .buttonStyle(.plain)

                    // Reset Button
                    Button(action: { confirmReset = true }) {
                        Text(L("resetToDefaults"))
                            .font(Design.Typo.body)
                            .foregroundColor(Design.Palette.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, Design.Space.s)
                }
                .padding(Design.Space.l)
            }
            .frame(maxHeight: 450)
        }
        .panelChrome(width: 500)
        .confirmationDialog(
            L("deleteCategoryConfirm", pendingDelete?.displayName ?? ""),
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button(L("delete"), role: .destructive) {
                if let category = pendingDelete {
                    withAnimation(Design.animation()) { categoryManager.deleteCategory(category) }
                }
                pendingDelete = nil
            }
            Button(L("cancel"), role: .cancel) { pendingDelete = nil }
        } message: {
            Text(L("deleteCategoryMessage", pendingDelete.map { counts[$0.id] ?? 0 } ?? 0))
        }
        .confirmationDialog(L("resetCategoriesConfirm"), isPresented: $confirmReset, titleVisibility: .visible) {
            Button(L("reset"), role: .destructive) {
                withAnimation(Design.animation()) { categoryManager.resetToDefaults() }
            }
            Button(L("cancel"), role: .cancel) {}
        } message: {
            Text(L("resetCategoriesMessage", categoryManager.appCategoryMap.count))
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategorySheet(isPresented: $showAddCategory)
        }
        .sheet(item: $editingCategory) { category in
            EditCategorySheet(category: category, isPresented: Binding(
                get: { editingCategory != nil },
                set: { if !$0 { editingCategory = nil } }
            ))
        }
        .sheet(item: $showAppSelector) { category in
            AppSelectorSheet(category: category, isPresented: Binding(
                get: { showAppSelector != nil },
                set: { if !$0 { showAppSelector = nil } }
            ))
        }
    }
}

// MARK: - Category Action Button
struct CategoryActionButton: View {
    let icon: String
    let helpText: String
    var isDestructive = false
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(isDestructive ? Design.Palette.danger : Design.Palette.textSecondary)
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(isHovered ? Design.Palette.raisedHover : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .help(helpText)
        .onHover { hovering in
            withAnimation(Design.animation()) { isHovered = hovering }
        }
    }
}

// MARK: - Category Row View
struct CategoryRowView: View {
    let category: CustomCategory
    let appCount: Int
    let onEdit: () -> Void
    let onManageApps: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false
    @ObservedObject var localization = LocalizationManager.shared

    var body: some View {
        HStack(spacing: Design.Space.m) {
            Image(systemName: category.icon)
                .font(.system(size: 18))
                .foregroundColor(Design.Palette.textSecondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(Design.Typo.bodyMedium)
                    .foregroundColor(Design.Palette.textPrimary)
                Text(L("appsCount", appCount))
                    .font(Design.Typo.count)
                    .foregroundColor(Design.Palette.textTertiary)
            }

            Spacer()

            // 操作按鈕 hover 才出現，平時保持清爽
            HStack(spacing: Design.Space.xs) {
                CategoryActionButton(icon: "square.grid.2x2", helpText: L("manageApps"), action: onManageApps)
                CategoryActionButton(icon: "pencil", helpText: L("editCategory"), action: onEdit)
                if category.categoryKey != CategoryManager.fallbackCategoryKey {
                    CategoryActionButton(icon: "trash", helpText: L("deleteCategory"),
                                         isDestructive: true, action: onDelete)
                }
            }
            .opacity(isHovered ? 1 : 0)
        }
        .padding(.horizontal, Design.Space.m)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Design.Radius.small)
                .fill(isHovered ? Design.Palette.raised : Color.clear)
        )
        .onHover { hovering in
            withAnimation(Design.animation()) { isHovered = hovering }
        }
    }
}

// MARK: - Add Category Sheet
struct AddCategorySheet: View {
    @Binding var isPresented: Bool
    @State private var categoryName = ""
    @State private var selectedIcon = "folder.fill"
    @ObservedObject var categoryManager = CategoryManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text(L("addCategory"))
                .font(Design.Typo.title)
                .foregroundColor(Design.Palette.textPrimary)

            TextField(L("categoryName"), text: $categoryName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)

            VStack(alignment: .leading, spacing: 10) {
                Text(L("selectIcon"))
                    .font(Design.Typo.body)
                    .foregroundColor(Design.Palette.textSecondary)

                IconPicker(selection: $selectedIcon)
            }

            HStack(spacing: 16) {
                Button(L("cancel")) {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Button(L("add")) {
                    if !categoryName.isEmpty {
                        categoryManager.addCategory(name: categoryName, icon: selectedIcon)
                        isPresented = false
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(categoryName.isEmpty)
            }
        }
        .padding(Design.Space.l)
        .sheetChrome(width: 320)
    }
}

// MARK: - Edit Category Sheet
struct EditCategorySheet: View {
    let category: CustomCategory
    @Binding var isPresented: Bool
    @State private var categoryName: String
    @State private var selectedIcon: String
    @ObservedObject var categoryManager = CategoryManager.shared

    init(category: CustomCategory, isPresented: Binding<Bool>) {
        self.category = category
        self._isPresented = isPresented
        self._categoryName = State(initialValue: category.displayName)
        self._selectedIcon = State(initialValue: category.icon)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(L("editCategory"))
                .font(Design.Typo.title)
                .foregroundColor(Design.Palette.textPrimary)

            TextField(L("categoryName"), text: $categoryName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)

            VStack(alignment: .leading, spacing: 10) {
                Text(L("selectIcon"))
                    .font(Design.Typo.body)
                    .foregroundColor(Design.Palette.textSecondary)

                IconPicker(selection: $selectedIcon)
            }

            HStack(spacing: 16) {
                Button(L("cancel")) {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Button(L("save")) {
                    if !categoryName.isEmpty {
                        var updatedCategory = category
                        updatedCategory.name = categoryName
                        updatedCategory.icon = selectedIcon
                        // 如果編輯的是預設分類，移除 categoryKey 讓它變成自訂分類
                        if category.categoryKey != nil {
                            updatedCategory.categoryKey = nil
                        }
                        categoryManager.updateCategory(updatedCategory)
                        isPresented = false
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(categoryName.isEmpty)
            }
        }
        .padding(Design.Space.l)
        .sheetChrome(width: 320)
    }
}

// MARK: - App Selector Sheet
struct AppSelectorSheet: View {
    let category: CustomCategory
    @Binding var isPresented: Bool
    @ObservedObject var categoryManager = CategoryManager.shared
    @ObservedObject var viewModel = LauncherViewModel.shared
    @State private var searchText = ""

    var filteredApps: [AppItem] {
        if searchText.isEmpty {
            return viewModel.apps
        }
        return viewModel.apps.filter { $0.matches(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Design.Space.s) {
                PanelHeader(title: category.displayName, icon: category.icon) { isPresented = false }
                    .padding(.horizontal, -Design.Space.l)
                    .padding(.top, -Design.Space.l)

                SearchField(placeholder: L("searchApps"), text: $searchText)
                    .frame(maxWidth: .infinity)
            }
            .padding(Design.Space.l)

            if filteredApps.isEmpty {
                EmptyStateView(icon: "magnifyingglass", title: L("noResults", searchText), hint: L("noResultsHint"))
            } else {
                ScrollView {
                    LazyVStack(spacing: Design.Space.xs) {
                        ForEach(filteredApps) { app in
                            AppSelectionRow(app: app, category: category)
                        }
                    }
                    .padding(.horizontal, Design.Space.m)
                    .padding(.bottom, Design.Space.m)
                }
            }

            HStack {
                Text(L("appsWillBeCategorized", category.displayName))
                    .font(Design.Typo.caption)
                    .foregroundColor(Design.Palette.textTertiary)
                Spacer()
                Button(L("done")) { isPresented = false }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(Design.Space.m)
        }
        .frame(height: 500)
        .sheetChrome(width: 460)
    }
}

// MARK: - App Selection Row
struct AppSelectionRow: View {
    let app: AppItem
    let category: CustomCategory
    @ObservedObject var categoryManager = CategoryManager.shared

    var isSelected: Bool {
        categoryManager.appCategoryMap[app.path] == category.id
    }

    var body: some View {
        Button(action: {
            if isSelected {
                categoryManager.setAppCategory(appPath: app.path, categoryId: nil)
            } else {
                categoryManager.setAppCategory(appPath: app.path, categoryId: category.id)
            }
        }) {
            HStack(spacing: Design.Space.m) {
                Image(nsImage: app.icon)
                    .resizable()
                    .frame(width: 28, height: 28)

                Text(app.name)
                    .font(Design.Typo.body)
                    .foregroundColor(Design.Palette.textPrimary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? Design.Palette.textPrimary : Design.Palette.textTertiary)
            }
            .padding(.horizontal, Design.Space.s)
            .padding(.vertical, Design.Space.s)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.small)
                    .fill(isSelected ? Design.Palette.raised : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Icon View
struct AppIconView: View {
    let app: AppItem
    let size: CGFloat
    var isSelected = false
    let onTap: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(nsImage: app.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.3), radius: 5)

                Text(app.name)
                    .font(size > 64 ? Design.Typo.body : Design.Typo.caption)
                    .foregroundColor(Design.Palette.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: size + 30)
                    .shadow(color: .black.opacity(0.5), radius: 2)
            }
            .padding(Design.Space.s)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.small)
                    .fill(isSelected ? Design.Palette.selection
                          : (isHovered ? Design.Palette.raised : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.Radius.small)
                    .stroke(Design.Palette.textPrimary, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
        .help(app.name)
        .onHover { hovering in
            withAnimation(Design.animation()) { isHovered = hovering }
        }
    }
}

// MARK: - Folder Card View
struct FolderCardView: View {
    let folder: FolderGroup
    let iconSize: CGFloat
    var isSelected = false
    let onTap: () -> Void
    @State private var isHovered = false
    @ObservedObject var localization = LocalizationManager.shared

    // Preview icon size - larger icons
    var previewIconSize: CGFloat {
        max(36, iconSize * 0.65)
    }

    var body: some View {
        Button(action: onTap) {
            // 預覽圖示與文字統一靠左，維持同一條視覺軸線
            VStack(alignment: .leading, spacing: Design.Space.m) {
                LazyVGrid(
                    columns: [GridItem(.fixed(previewIconSize), spacing: Design.Space.s),
                              GridItem(.fixed(previewIconSize), spacing: Design.Space.s)],
                    alignment: .leading,
                    spacing: Design.Space.s
                ) {
                    ForEach(0..<4, id: \.self) { index in
                        if index < folder.previewApps.count {
                            Image(nsImage: folder.previewApps[index].icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: previewIconSize, height: previewIconSize)
                                .shadow(color: .black.opacity(0.3), radius: 3)
                        } else {
                            Color.clear
                                .frame(width: previewIconSize, height: previewIconSize)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Design.Space.xs) {
                        Image(systemName: folder.icon)
                            .font(.system(size: 12))
                            .foregroundColor(Design.Palette.textSecondary)
                        Text(folder.title)
                            .font(Design.Typo.bodyMedium)
                            .foregroundColor(Design.Palette.textPrimary)
                            .lineLimit(1)
                    }
                    Text(L("appsCount", folder.count))
                        .font(Design.Typo.count)
                        .foregroundColor(Design.Palette.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Design.Space.m)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.large)
                    .fill(isSelected ? Design.Palette.selection
                          : (isHovered ? Design.Palette.raisedHover : Design.Palette.raised))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.Radius.large)
                    .stroke(isSelected ? Design.Palette.textPrimary : Design.Palette.stroke,
                            lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(Design.animation()) { isHovered = hovering }
        }
    }
}

// MARK: - Shared Components
struct TopBarButton: View {
    let icon: String
    let help: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Design.Palette.textSecondary)
                .frame(width: 32, height: 32)
                .background(Circle().fill(isHovered ? Design.Palette.raisedHover : Design.Palette.raised))
        }
        .buttonStyle(.plain)
        .help(help)
        .onHover { hovering in
            withAnimation(Design.animation()) { isHovered = hovering }
        }
    }
}

struct SearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: Design.Space.s) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundColor(Design.Palette.textTertiary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(Design.Typo.body)
                .foregroundColor(Design.Palette.textPrimary)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Design.Palette.textTertiary)
                }
                .buttonStyle(.plain)
                .help(L("clearSearch"))
            }
        }
        .padding(.horizontal, Design.Space.m)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Design.Radius.small)
                .fill(Design.Palette.raised)
        )
        .frame(maxWidth: 360)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let hint: String

    var body: some View {
        VStack(spacing: Design.Space.s) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(Design.Palette.textTertiary)
                .padding(.bottom, Design.Space.xs)
            Text(title)
                .font(Design.Typo.title)
                .foregroundColor(Design.Palette.textSecondary)
            Text(hint)
                .font(Design.Typo.body)
                .foregroundColor(Design.Palette.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 搜尋結果、資料夾內頁、平鋪模式共用同一組格線，切換時版面不跳動
struct AppGridView: View {
    let apps: [AppItem]
    var showsCategoryLabel = false
    @ObservedObject var settings = LauncherSettings.shared
    @ObservedObject var viewModel = LauncherViewModel.shared

    var body: some View {
        GeometryReader { geometry in
            let columns = columnCount(for: geometry.size.width)
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: settings.gridSpacing), count: columns),
                        spacing: settings.gridSpacing
                    ) {
                        ForEach(Array(apps.enumerated()), id: \.element.id) { index, app in
                            VStack(spacing: 2) {
                                AppIconView(app: app, size: settings.iconSize,
                                            isSelected: index == viewModel.selection) {
                                    viewModel.selection = index
                                    viewModel.launchApp(app)
                                }
                                // 搜尋時保留分類脈絡
                                if showsCategoryLabel, let category = app.category {
                                    Text(category.displayName)
                                        .font(Design.Typo.caption)
                                        .foregroundColor(Design.Palette.textTertiary)
                                        .lineLimit(1)
                                }
                            }
                            .id(index)
                        }
                    }
                    .padding(.horizontal, Design.Space.xxl)
                    .padding(.vertical, Design.Space.l)
                }
                .compatOnChange(of: viewModel.selection) {
                    withAnimation(Design.animation()) {
                        proxy.scrollTo(viewModel.selection, anchor: .center)
                    }
                }
            }
            .onAppear { report(columns) }
            .compatOnChange(of: columns) { report(columns) }
        }
    }

    private func report(_ columns: Int) {
        DispatchQueue.main.async { viewModel.columns = columns }
    }

    private func columnCount(for width: CGFloat) -> Int {
        let itemWidth = settings.iconSize + 50
        let usable = width - Design.Space.xxl * 2
        return max(1, Int(usable / max(itemWidth, 1)))
    }
}

// MARK: - Folder Grid View
struct FolderGridView: View {
    let folders: [FolderGroup]
    let onFolderTap: (UUID) -> Void
    @ObservedObject var settings = LauncherSettings.shared
    @ObservedObject var viewModel = LauncherViewModel.shared

    var body: some View {
        GeometryReader { geometry in
            let columns = columnCount(for: geometry.size.width)
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: Design.Space.m), count: columns),
                    spacing: Design.Space.m
                ) {
                    ForEach(Array(folders.enumerated()), id: \.element.id) { index, folder in
                        FolderCardView(folder: folder, iconSize: settings.iconSize,
                                       isSelected: index == viewModel.selection) {
                            viewModel.selection = index
                            onFolderTap(folder.id)
                        }
                    }
                }
                .padding(.horizontal, Design.Space.xxl)
                // 內容垂直置中，不再全部擠在上半部
                .frame(minHeight: geometry.size.height, alignment: .center)
            }
            .onAppear { report(columns) }
            .compatOnChange(of: columns) { report(columns) }
        }
    }

    private func report(_ columns: Int) {
        DispatchQueue.main.async { viewModel.columns = columns }
    }

    private func columnCount(for width: CGFloat) -> Int {
        let cardWidth = settings.iconSize * 2.2 + 80
        let usable = width - Design.Space.xxl * 2
        return max(2, min(8, Int(usable / max(cardWidth, 1))))
    }
}

// MARK: - Folder Detail Overlay
struct FolderDetailOverlay: View {
    let folder: FolderGroup
    let apps: [AppItem]
    @Binding var searchQuery: String
    let onBack: () -> Void
    @ObservedObject var settings = LauncherSettings.shared
    @ObservedObject var localization = LocalizationManager.shared

    var body: some View {
        VStack(spacing: Design.Space.m) {
            HStack(spacing: Design.Space.m) {
                Button(action: onBack) {
                    HStack(spacing: Design.Space.xs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text(L("back"))
                            .font(Design.Typo.body)
                    }
                    .foregroundColor(Design.Palette.textSecondary)
                    .padding(.horizontal, Design.Space.m)
                    .padding(.vertical, Design.Space.s)
                    .background(Capsule().fill(Design.Palette.raised))
                }
                .buttonStyle(.plain)

                HStack(spacing: Design.Space.s) {
                    Image(systemName: folder.icon)
                        .font(.system(size: 16))
                        .foregroundColor(Design.Palette.textSecondary)
                    Text(folder.title)
                        .font(Design.Typo.display)
                        .foregroundColor(Design.Palette.textPrimary)
                    Text(L("appsCount", apps.count))
                        .font(Design.Typo.count)
                        .foregroundColor(Design.Palette.textTertiary)
                }

                Spacer()

                SearchField(placeholder: L("searchThisCategory"), text: $searchQuery)
            }
            .padding(.horizontal, Design.Space.xxl)
            .padding(.top, Design.Space.xl)

            if apps.isEmpty {
                if searchQuery.isEmpty {
                    EmptyStateView(icon: "square.dashed", title: L("emptyCategory"), hint: L("emptyCategoryHint"))
                } else {
                    EmptyStateView(icon: "magnifyingglass", title: L("noResults", searchQuery), hint: L("noResultsHint"))
                }
            } else {
                AppGridView(apps: apps)
            }

            Color.clear.frame(height: Design.Space.l)
        }
        .background(Color.black.opacity(0.2).ignoresSafeArea())
        .transition(.opacity)
    }
}

// MARK: - Main Launcher View
struct LauncherView: View {
    @ObservedObject private var viewModel = LauncherViewModel.shared
    @ObservedObject var settings = LauncherSettings.shared
    @ObservedObject var categoryManager = CategoryManager.shared
    @ObservedObject var localization = LocalizationManager.shared

    var body: some View {
        ZStack {
            VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)
                .ignoresSafeArea()

            // 點背景空白處關閉，與 Launchpad 的行為一致
            Color.black.opacity(settings.backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture { (NSApp.delegate as? AppDelegate)?.hideLauncher() }

            content

            if viewModel.showSettings {
                scrim { viewModel.showSettings = false }
                SettingsView(isPresented: $viewModel.showSettings)
            }

            if viewModel.showCategoryManager {
                scrim { viewModel.showCategoryManager = false }
                CategoryManagerView(isPresented: $viewModel.showCategoryManager)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var content: some View {
        if settings.showCategories, case .folderDetail = viewModel.route, let folder = viewModel.activeFolder {
            FolderDetailOverlay(
                folder: folder,
                apps: viewModel.filteredFolderApps,
                searchQuery: $viewModel.folderQuery,
                onBack: { viewModel.navigateToHome() }
            )
        } else {
            VStack(spacing: Design.Space.m) {
                topBar
                mainArea
                bottomHint
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: Design.Space.s) {
            TopBarButton(icon: "gearshape", help: L("settings")) {
                viewModel.showSettings.toggle()
            }
            TopBarButton(icon: "folder.badge.gearshape", help: L("categoryManager")) {
                viewModel.showCategoryManager.toggle()
            }

            Spacer()

            SearchField(
                placeholder: settings.showCategories ? L("searchCategoryOrApps") : L("searchApps"),
                text: $viewModel.searchText
            )

            Spacer()

            TopBarButton(icon: "arrow.clockwise", help: L("refresh")) {
                viewModel.refresh()
            }
        }
        .padding(.horizontal, Design.Space.xxl)
        .padding(.top, Design.Space.xl)
    }

    @ViewBuilder
    private var mainArea: some View {
        if viewModel.apps.isEmpty {
            EmptyStateView(icon: "square.grid.2x2", title: L("noApps"), hint: L("noAppsHint"))
        } else if !viewModel.searchText.isEmpty {
            if viewModel.filteredApps.isEmpty {
                EmptyStateView(icon: "magnifyingglass",
                               title: L("noResults", viewModel.searchText),
                               hint: L("noResultsHint"))
            } else {
                AppGridView(apps: viewModel.filteredApps, showsCategoryLabel: settings.showCategories)
            }
        } else if settings.showCategories {
            FolderGridView(folders: viewModel.folderGroups) { folderId in
                viewModel.navigateToFolder(id: folderId)
            }
        } else {
            AppGridView(apps: viewModel.filteredApps)
        }
    }

    // 操作提示只在前幾次開啟時出現，熟練之後不再佔版面
    private var bottomHint: some View {
        Group {
            if settings.openCount <= 5 {
                Text("\(L("hintKeyboard"))     \(L("hintHotkey")): \(settings.hotkeyDescription)")
                    .font(Design.Typo.caption)
                    .foregroundColor(Design.Palette.textTertiary)
            }
        }
        .frame(height: Design.Space.m)
        .padding(.bottom, Design.Space.xl)
    }

    private func scrim(_ action: @escaping () -> Void) -> some View {
        Design.Palette.overlayScrim
            .ignoresSafeArea()
            .onTapGesture(perform: action)
    }
}

// MARK: - Visual Effect View
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Directory Monitor
class DirectoryMonitor {
    private var sources: [DispatchSourceFileSystemObject] = []
    private var fileDescriptors: [Int32] = []
    private var debounceWorkItem: DispatchWorkItem?

    func startMonitoring(onChange: @escaping () -> Void) {
        let directories = [
            "/Applications",
            "/System/Applications",
            "/System/Applications/Utilities",
            NSHomeDirectory() + "/Applications"
        ]

        for dir in directories {
            let fd = open(dir, O_EVTONLY)
            guard fd >= 0 else { continue }
            fileDescriptors.append(fd)

            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fd,
                eventMask: [.write, .rename],
                queue: .main
            )
            source.setEventHandler { [weak self] in
                self?.debounceWorkItem?.cancel()
                let work = DispatchWorkItem { onChange() }
                self?.debounceWorkItem = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
            }
            source.setCancelHandler { close(fd) }
            source.resume()
            sources.append(source)
        }
    }

    func stopMonitoring() {
        sources.forEach { $0.cancel() }
        sources.removeAll()
        fileDescriptors.removeAll()
    }
}

// MARK: - Hotkey Manager
class HotkeyManager {
    static let shared = HotkeyManager()
    private var eventHotKey: EventHotKeyRef?
    private var registeredKeyCode: UInt32?
    private var registeredModifiers: UInt32?

    func registerHotkey() {
        let settings = LauncherSettings.shared
        update(keyCode: settings.hotkeyKeyCode, modifiers: settings.hotkeyModifiers)
    }

    /// 先註冊新組合、成功後才解除舊的；失敗時舊快捷鍵維持有效
    @discardableResult
    func update(keyCode: UInt32, modifiers: UInt32) -> OSStatus {
        if eventHotKey != nil, keyCode == registeredKeyCode, modifiers == registeredModifiers {
            return noErr
        }

        let hotKeyID = EventHotKeyID(signature: OSType(0x4C4E4348), id: 1) // "LNCH"
        var newRef: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &newRef)
        guard status == noErr else { return status }

        if let oldRef = eventHotKey {
            UnregisterEventHotKey(oldRef)
        }
        eventHotKey = newRef
        registeredKeyCode = keyCode
        registeredModifiers = modifiers
        return noErr
    }
}

// MARK: - Hotkey Recorder
/// 錄製新快捷鍵：ESC 取消；註冊失敗時不寫入設定並回報原因
class HotkeyRecorder: ObservableObject {
    static let shared = HotkeyRecorder()
    @Published private(set) var isRecording = false
    @Published private(set) var errorMessage: String?
    private var monitor: Any?

    private var timeout: DispatchWorkItem?

    func start() {
        guard monitor == nil else { return }
        errorMessage = nil
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.capture(event)
            return nil
        }
        // 媒體鍵等事件不是 keyDown，收不到時錄製會一直卡著，給它一個出口
        let work = DispatchWorkItem { [weak self] in
            guard let self = self, self.isRecording else { return }
            self.cancel()
            self.errorMessage = L("hotkeyRecordingTimeout")
        }
        timeout = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: work)
    }

    func cancel() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
        timeout?.cancel()
        timeout = nil
        isRecording = false
    }

    private func capture(_ event: NSEvent) {
        defer { cancel() }
        guard event.keyCode != UInt16(kVK_Escape) else { return }

        let keyCode = UInt32(event.keyCode)
        let modifiers = Self.carbonModifiers(from: event.modifierFlags)

        // 無修飾鍵的一般按鍵會攔截全系統的輸入（打字時到處觸發），只放行 F 鍵
        guard modifiers != 0 || Self.functionKeyCodes.contains(keyCode) else {
            errorMessage = L("hotkeyNeedsModifier")
            return
        }
        // 系統快捷鍵（如 ⌘Space）註冊時不會失敗，但按下去永遠不會傳到這裡
        guard !Self.isSystemShortcut(keyCode: keyCode, modifiers: modifiers) else {
            errorMessage = L("hotkeySystemReserved")
            return
        }

        let status = HotkeyManager.shared.update(keyCode: keyCode, modifiers: modifiers)
        guard status == noErr else {
            errorMessage = status == OSStatus(eventHotKeyExistsErr)
                ? L("hotkeyInUse")
                : L("hotkeyRegisterFailed", Int(status))
            return
        }

        let settings = LauncherSettings.shared
        settings.hotkeyKeyCode = keyCode
        settings.hotkeyModifiers = modifiers
    }

    // F1–F20；這些鍵單獨當快捷鍵不會干擾打字
    private static let functionKeyCodes: Set<UInt32> = [
        0x7A, 0x78, 0x63, 0x76, 0x60, 0x61, 0x62, 0x64, 0x65, 0x6D, 0x67, 0x6F,
        0x69, 0x6B, 0x71, 0x6A, 0x40, 0x4F, 0x50, 0x5A
    ]

    private static let modifierMask = UInt32(cmdKey | shiftKey | optionKey | controlKey)

    /// 比對 macOS 系統快捷鍵（Spotlight、Mission Control 等）
    private static func isSystemShortcut(keyCode: UInt32, modifiers: UInt32) -> Bool {
        var raw: Unmanaged<CFArray>?
        guard CopySymbolicHotKeys(&raw) == noErr,
              let entries = raw?.takeRetainedValue() as? [[String: Any]] else { return false }

        return entries.contains { entry in
            guard entry[kHISymbolicHotKeyEnabled as String] as? Bool == true,
                  let code = entry[kHISymbolicHotKeyCode as String] as? Int,
                  let mods = entry[kHISymbolicHotKeyModifiers as String] as? Int else { return false }
            return UInt32(code) == keyCode
                && UInt32(mods) & modifierMask == modifiers & modifierMask
        }
    }

    private static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var modifiers: UInt32 = 0
        if flags.contains(.command) { modifiers |= UInt32(cmdKey) }
        if flags.contains(.option) { modifiers |= UInt32(optionKey) }
        if flags.contains(.control) { modifiers |= UInt32(controlKey) }
        if flags.contains(.shift) { modifiers |= UInt32(shiftKey) }
        return modifiers
    }
}

// MARK: - Key-Accepting Borderless Window
class KeyableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var statusItem: NSStatusItem?
    var directoryMonitor = DirectoryMonitor()
    var escMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "square.grid.3x3.fill", accessibilityDescription: "Launcher")
            button.action = #selector(toggleWindow)
        }

        // Setup menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: L("openLauncher"), action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: L("quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu

        // Register global hotkey
        HotkeyManager.shared.registerHotkey()

        // Install event handler for hotkey
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { (_, event, _) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)

            if hotKeyID.id == 1 {
                DispatchQueue.main.async {
                    if let delegate = NSApplication.shared.delegate as? AppDelegate {
                        delegate.toggleWindow()
                    }
                }
            }
            return noErr
        }, 1, &eventSpec, nil, nil)

        // 鍵盤操作：ESC 分層返回、方向鍵選取、Return 開啟
        escMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, let window = self.window, window.isVisible else { return event }

            if event.keyCode == UInt16(kVK_Escape) {
                return self.handleEscape(in: window) ? nil : event
            }
            return self.handleNavigation(event, in: window) ? nil : event
        }

        // Monitor app directories for changes
        directoryMonitor.startMonitoring {
            LauncherViewModel.shared.refresh()
        }

        // Delay initial window show to avoid blocking screen on reboot/login
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showWindow()
        }
    }

    /// ESC 由最上層往下處理：sheet → 快捷鍵錄製 → 設定/分類面板 → 資料夾搜尋 → 資料夾 → 首頁搜尋 → 主視窗
    /// 回傳 false 表示不攔截，讓事件交給 sheet 的取消鍵或快捷鍵錄製器
    private func handleEscape(in window: NSWindow) -> Bool {
        if window.attachedSheet != nil || HotkeyRecorder.shared.isRecording {
            return false
        }

        let viewModel = LauncherViewModel.shared
        if viewModel.showSettings {
            viewModel.showSettings = false
        } else if viewModel.showCategoryManager {
            viewModel.showCategoryManager = false
        } else if LauncherSettings.shared.showCategories, case .folderDetail = viewModel.route {
            if viewModel.folderQuery.isEmpty {
                viewModel.navigateToHome()
            } else {
                viewModel.folderQuery = ""
            }
        } else if !viewModel.searchText.isEmpty {
            viewModel.searchText = ""
        } else {
            hideLauncher()
        }
        return true
    }

    /// 方向鍵移動選取、Return 開啟；面板或 sheet 開著時不攔截
    private func handleNavigation(_ event: NSEvent, in window: NSWindow) -> Bool {
        let viewModel = LauncherViewModel.shared
        guard window.attachedSheet == nil,
              !HotkeyRecorder.shared.isRecording,
              !viewModel.showSettings,
              !viewModel.showCategoryManager,
              !event.modifierFlags.contains(.command) else { return false }

        switch Int(event.keyCode) {
        case kVK_LeftArrow: viewModel.moveSelection(dx: -1, dy: 0)
        case kVK_RightArrow: viewModel.moveSelection(dx: 1, dy: 0)
        case kVK_UpArrow: viewModel.moveSelection(dx: 0, dy: -1)
        case kVK_DownArrow: viewModel.moveSelection(dx: 0, dy: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter: viewModel.activateSelection()
        default: return false
        }
        return true
    }

    /// 關閉啟動器並把焦點交還給原本的 App
    func hideLauncher() {
        window?.orderOut(nil)
        NSApp.hide(nil)
    }

    @objc func toggleWindow() {
        if let window = window, window.isVisible {
            hideLauncher()
        } else {
            showWindow()
        }
    }

    @objc func showWindow() {
        if window == nil {
            guard let screen = NSScreen.main else { return }

            window = KeyableWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )

            window?.level = .screenSaver
            window?.backgroundColor = .clear
            window?.isOpaque = false
            window?.hasShadow = false
            window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            let contentView = LauncherView()
            window?.contentView = NSHostingView(rootView: contentView)
        }

        // Update frame in case screen changed
        if let screen = NSScreen.main {
            window?.setFrame(screen.frame, display: true)
        }

        // 淡入，避免視窗硬跳出來；系統開啟「減少動態效果」時直接顯示
        window?.alphaValue = Design.reduceMotion ? 1 : 0
        window?.makeKeyAndOrderFront(nil)
        window?.makeFirstResponder(window?.contentView)
        if !Design.reduceMotion, let window = window {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                window.animator().alphaValue = 1
            }
        }

        // Refresh app list to pick up newly installed apps
        LauncherViewModel.shared.refresh()

        // Reset to home state when showing window
        let viewModel = LauncherViewModel.shared
        viewModel.route = .home
        viewModel.folderQuery = ""
        viewModel.searchText = ""
        viewModel.showSettings = false
        viewModel.showCategoryManager = false
        viewModel.selection = 0
        LauncherSettings.shared.openCount += 1

        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showWindow()
        return true
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // 當從 Dock 點擊時也顯示視窗
        if window == nil || !window!.isVisible {
            showWindow()
        }
    }
}

// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
