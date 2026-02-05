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
            "hintEscClose": "按 ESC 關閉",
            "hintEscBack": "按 ESC 返回",
            "hintHotkey": "快捷鍵",
            "hintClickCategory": "點擊分類進入",
            "hintClickSettings": "點擊 ⚙️ 開啟設定",

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
            "hintEscClose": "Press ESC to close",
            "hintEscBack": "Press ESC to go back",
            "hintHotkey": "Hotkey",
            "hintClickCategory": "Click category to enter",
            "hintClickSettings": "Click ⚙️ for settings",

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

    init() {
        self.iconSize = UserDefaults.standard.object(forKey: "iconSize") as? CGFloat ?? 64
        self.gridSpacing = UserDefaults.standard.object(forKey: "gridSpacing") as? CGFloat ?? 25
        self.showCategories = UserDefaults.standard.object(forKey: "showCategories") as? Bool ?? true
        self.backgroundOpacity = UserDefaults.standard.object(forKey: "backgroundOpacity") as? Double ?? 0.6
        self.hotkeyKeyCode = UserDefaults.standard.object(forKey: "hotkeyKeyCode") as? UInt32 ?? 0x7A  // F1
        self.hotkeyModifiers = UserDefaults.standard.object(forKey: "hotkeyModifiers") as? UInt32 ?? UInt32(cmdKey | optionKey)

        if let behaviorString = UserDefaults.standard.string(forKey: "launchBehavior"),
           let behavior = LaunchBehavior(rawValue: behaviorString) {
            self.launchBehavior = behavior
        } else {
            self.launchBehavior = .closeAfterLaunch
        }
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

    // 遷移：為舊使用者補上新增的預設分類
    private func migrateAddNewDefaultCategories() {
        let existingKeys = Set(categories.compactMap { $0.categoryKey })
        let newDefaults = defaultCategories.filter {
            guard let key = $0.categoryKey else { return false }
            return !existingKeys.contains(key)
        }

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

        // 否則使用自動分類
        return autoCategorizePapp(appName: appName, path: appPath)
    }

    private func findCategory(byKey key: String) -> CustomCategory? {
        // 優先用 categoryKey 匹配，回退到名稱匹配
        return categories.first { $0.categoryKey == key }
    }

    private func autoCategorizePapp(appName: String, path: String) -> CustomCategory? {
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
            "vectornator", "linearity", "colorsnapper", "cinema 4d", "maya"
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
            "dash", "rapidapi", "httpie"
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
            "downie", "movist", "elmedia", "vox", "tidal", "deezer"
        ]
        if mediaKeywords.contains(where: { name.contains($0) }) {
            return findCategory(byKey: "media")
        }

        // 5. Social
        let socialKeywords = [
            "message", "mail", "slack", "discord", "telegram", "whatsapp",
            "zoom", "teams", "facetime", "line", "wechat", "skype",
            "signal", "viber", "lark", "feishu", "dingtalk", "webex",
            "thunderbird", "spark", "airmail", "mimestream"
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
            "acrobat", "alfred", "raycast"
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
            "automator", "shortcut", "migration"
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
    let name: String
    let path: String
    let icon: NSImage

    var category: CustomCategory? {
        CategoryManager.shared.getCategoryForApp(appPath: path, appName: name)
    }

    init(name: String, path: String, icon: NSImage) {
        self.name = name
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
                if item.hasSuffix(".app") {
                    let fullPath = "\(directory)/\(item)"
                    let appName = item.replacingOccurrences(of: ".app", with: "")

                    let icon = NSWorkspace.shared.icon(forFile: fullPath)
                    icon.size = NSSize(width: 128, height: 128)

                    apps.append(AppItem(name: appName, path: fullPath, icon: icon))
                }
            }
        }

        return apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
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
    @Published var searchText: String = ""
    @Published var selectedCategory: CustomCategory? = nil
    @Published var showSettings: Bool = false
    @Published var showCategoryManager: Bool = false

    // Folder browsing state
    @Published var route: LauncherRoute = .home
    @Published var folderQuery: String = ""

    @ObservedObject var categoryManager = CategoryManager.shared

    var filteredApps: [AppItem] {
        var result = apps

        if let category = selectedCategory {
            result = result.filter { $0.category?.id == category.id }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var groupedApps: [(CustomCategory, [AppItem])] {
        let filtered = filteredApps
        var grouped: [UUID: [AppItem]] = [:]

        for app in filtered {
            if let category = app.category {
                grouped[category.id, default: []].append(app)
            }
        }

        return categoryManager.categories.compactMap { category in
            guard let apps = grouped[category.id], !apps.isEmpty else { return nil }
            return (category, apps)
        }
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
        return folder.apps.filter { $0.name.localizedCaseInsensitiveContains(folderQuery) }
    }

    init() {
        apps = AppScanner.scanApplications()
    }

    func navigateToFolder(id: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            route = .folderDetail(folderId: id)
            folderQuery = ""
        }
    }

    func navigateToHome() {
        withAnimation(.easeInOut(duration: 0.2)) {
            route = .home
            folderQuery = ""
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

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var settings = LauncherSettings.shared
    @ObservedObject var localization = LocalizationManager.shared
    @Binding var isPresented: Bool
    @State private var isRecordingHotkey = false

    // Animation triggers
    @State private var iconSizeBounce = 0
    @State private var spacingBounce = 0
    @State private var opacityBounce = 0
    @State private var categoryBounce = 0
    @State private var hotkeyBounce = 0
    @State private var launchBehaviorBounce = 0
    @State private var languageBounce = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header - 固定在頂部
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .symbolEffect(.rotate, value: isPresented)
                Text(L("settings"))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                        .symbolEffect(.bounce, value: isPresented)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(Color(nsColor: NSColor.windowBackgroundColor))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Icon Size
                    AnimatedSettingSection(
                        title: L("iconSize"),
                        icon: "square.grid.2x2.fill",
                        animationTrigger: iconSizeBounce
                    ) {
                        HStack {
                            Text("\(Int(settings.iconSize))")
                                .foregroundColor(.primary)
                                .frame(width: 40)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            Slider(value: $settings.iconSize, in: 48...128, step: 8)
                                .tint(.blue)
                                .onChange(of: settings.iconSize) { _, _ in
                                    iconSizeBounce += 1
                                }
                            Image(systemName: "app.fill")
                                .font(.system(size: settings.iconSize / 3))
                                .foregroundColor(.blue.opacity(0.6))
                                .symbolEffect(.bounce, value: iconSizeBounce)
                        }
                    }

                    // Grid Spacing
                    AnimatedSettingSection(
                        title: L("gridSpacing"),
                        icon: "arrow.left.arrow.right",
                        animationTrigger: spacingBounce
                    ) {
                        HStack {
                            Text("\(Int(settings.gridSpacing))")
                                .foregroundColor(.primary)
                                .frame(width: 40)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            Slider(value: $settings.gridSpacing, in: 10...60, step: 5)
                                .tint(.green)
                                .onChange(of: settings.gridSpacing) { _, _ in
                                    spacingBounce += 1
                                }
                        }
                    }

                    // Background Opacity
                    AnimatedSettingSection(
                        title: L("backgroundDepth"),
                        icon: "circle.lefthalf.filled",
                        animationTrigger: opacityBounce
                    ) {
                        HStack {
                            Text("\(Int(settings.backgroundOpacity * 100))%")
                                .foregroundColor(.primary)
                                .frame(width: 50)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            Slider(value: $settings.backgroundOpacity, in: 0.1...0.9, step: 0.1)
                                .tint(.purple)
                                .onChange(of: settings.backgroundOpacity) { _, _ in
                                    opacityBounce += 1
                                }
                        }
                    }

                    // Show Categories
                    AnimatedSettingSection(
                        title: L("showCategories"),
                        icon: settings.showCategories ? "folder.fill" : "folder",
                        animationTrigger: categoryBounce
                    ) {
                        Toggle(L("groupByCategory"), isOn: $settings.showCategories)
                            .toggleStyle(.switch)
                            .tint(.orange)
                            .onChange(of: settings.showCategories) { _, _ in
                                categoryBounce += 1
                            }
                    }

                    // Launch Behavior
                    AnimatedSettingSection(
                        title: L("launchBehavior"),
                        icon: "arrow.up.forward.app.fill",
                        animationTrigger: launchBehaviorBounce
                    ) {
                        Picker("", selection: $settings.launchBehavior) {
                            ForEach(LaunchBehavior.allCases, id: \.self) { behavior in
                                Text(behavior.displayName).tag(behavior)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: settings.launchBehavior) { _, _ in
                            launchBehaviorBounce += 1
                        }
                    }

                    // Hotkey
                    AnimatedSettingSection(
                        title: L("globalHotkey"),
                        icon: "command.circle.fill",
                        animationTrigger: hotkeyBounce
                    ) {
                        HStack {
                            Text(settings.hotkeyDescription)
                                .foregroundColor(.primary)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isRecordingHotkey ? Color.red.opacity(0.2) : Color(nsColor: NSColor.controlBackgroundColor))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(isRecordingHotkey ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .symbolEffect(.pulse, isActive: isRecordingHotkey)

                            Spacer()

                            Button(action: {
                                isRecordingHotkey.toggle()
                                hotkeyBounce += 1
                                if isRecordingHotkey {
                                    startRecordingHotkey()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isRecordingHotkey ? "stop.circle.fill" : "record.circle")
                                        .symbolEffect(.bounce, value: hotkeyBounce)
                                    Text(isRecordingHotkey ? L("cancel") : L("modify"))
                                }
                                .foregroundColor(isRecordingHotkey ? .red : .blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isRecordingHotkey ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Language
                    AnimatedSettingSection(
                        title: L("language"),
                        icon: "globe",
                        animationTrigger: languageBounce
                    ) {
                        Picker("", selection: $localization.currentLanguage) {
                            ForEach(AppLanguage.allCases, id: \.self) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: localization.currentLanguage) { _, _ in
                            languageBounce += 1
                        }
                    }

                    Spacer(minLength: 10)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .frame(maxHeight: 520)
        }
        .frame(width: 500)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.5), radius: 30)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    func startRecordingHotkey() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if self.isRecordingHotkey {
                var modifiers: UInt32 = 0
                if event.modifierFlags.contains(.command) { modifiers |= UInt32(cmdKey) }
                if event.modifierFlags.contains(.option) { modifiers |= UInt32(optionKey) }
                if event.modifierFlags.contains(.control) { modifiers |= UInt32(controlKey) }
                if event.modifierFlags.contains(.shift) { modifiers |= UInt32(shiftKey) }

                self.settings.hotkeyKeyCode = UInt32(event.keyCode)
                self.settings.hotkeyModifiers = modifiers
                self.isRecordingHotkey = false
                self.hotkeyBounce += 1

                // Re-register hotkey
                HotkeyManager.shared.registerHotkey()

                return nil
            }
            return event
        }
    }
}

// MARK: - Animated Setting Section
struct AnimatedSettingSection<Content: View>: View {
    let title: String
    let icon: String
    let animationTrigger: Int
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                    .symbolEffect(.bounce, value: animationTrigger)
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: NSColor.controlBackgroundColor).opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Category Manager View
struct CategoryManagerView: View {
    @Binding var isPresented: Bool
    @ObservedObject var categoryManager = CategoryManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    @State private var showAddCategory = false
    @State private var editingCategory: CustomCategory? = nil
    @State private var showAppSelector: CustomCategory? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header - 固定在頂部
            HStack {
                Image(systemName: "folder.badge.gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                Text(L("categoryManager"))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(Color(nsColor: NSColor.windowBackgroundColor))

            Divider()

            // Category List - 可滾動區域
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(categoryManager.categories) { category in
                        CategoryRowView(
                            category: category,
                            onEdit: { editingCategory = category },
                            onManageApps: { showAppSelector = category },
                            onDelete: {
                                withAnimation {
                                    categoryManager.deleteCategory(category)
                                }
                            }
                        )
                    }

                    // Add Category Button
                    Button(action: { showAddCategory = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text(L("addCategory"))
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8]))
                        )
                    }
                    .buttonStyle(.plain)

                    // Reset Button
                    Button(action: {
                        categoryManager.resetToDefaults()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text(L("resetToDefaults"))
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                }
                .padding(20)
            }
            .frame(maxHeight: 450)
        }
        .frame(width: 500)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.5), radius: 30)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
    let color: Color
    let helpText: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .padding(8)
                .background(Circle().fill(color.opacity(isHovered ? 0.25 : 0.1)))
                .scaleEffect(isHovered ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
        .help(helpText)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Category Row View
struct CategoryRowView: View {
    let category: CustomCategory
    let onEdit: () -> Void
    let onManageApps: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false
    @State private var appCount: Int = 0
    @ObservedObject var categoryManager = CategoryManager.shared
    @ObservedObject var localization = LocalizationManager.shared

    func calculateAppCount() -> Int {
        let apps = AppScanner.scanApplications()
        return apps.filter { app in
            categoryManager.getCategoryForApp(appPath: app.path, appName: app.name)?.id == category.id
        }.count
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text(L("appsCount", appCount))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 按鈕持續顯示，各自獨立 hover 效果
            HStack(spacing: 8) {
                CategoryActionButton(
                    icon: "square.grid.2x2",
                    color: .blue,
                    helpText: L("manageApps"),
                    action: onManageApps
                )

                CategoryActionButton(
                    icon: "pencil",
                    color: .orange,
                    helpText: L("editCategory"),
                    action: onEdit
                )

                CategoryActionButton(
                    icon: "trash",
                    color: .red,
                    helpText: L("deleteCategory"),
                    action: onDelete
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovered ? Color(nsColor: NSColor.controlBackgroundColor) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onAppear {
            appCount = calculateAppCount()
        }
    }
}

// MARK: - Add Category Sheet
struct AddCategorySheet: View {
    @Binding var isPresented: Bool
    @State private var categoryName = ""
    @State private var selectedIcon = "folder.fill"
    @ObservedObject var categoryManager = CategoryManager.shared

    let availableIcons = [
        "folder.fill", "star.fill", "heart.fill", "bookmark.fill",
        "tag.fill", "briefcase.fill", "hammer.fill", "wrench.fill",
        "gamecontroller.fill", "music.note", "photo.fill", "video.fill",
        "message.fill", "envelope.fill", "globe", "book.fill",
        "graduationcap.fill", "paintbrush.fill", "camera.fill", "film.fill"
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text(L("addCategory"))
                .font(.system(size: 18, weight: .semibold))

            TextField(L("categoryName"), text: $categoryName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)

            VStack(alignment: .leading, spacing: 10) {
                Text(L("selectIcon"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(44)), count: 5), spacing: 10) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Button(action: { selectedIcon = icon }) {
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedIcon == icon ? .white : .blue)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedIcon == icon ? Color.blue : Color.blue.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
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
        .padding(30)
        .frame(width: 320)
    }
}

// MARK: - Edit Category Sheet
struct EditCategorySheet: View {
    let category: CustomCategory
    @Binding var isPresented: Bool
    @State private var categoryName: String
    @State private var selectedIcon: String
    @ObservedObject var categoryManager = CategoryManager.shared

    let availableIcons = [
        "folder.fill", "star.fill", "heart.fill", "bookmark.fill",
        "tag.fill", "briefcase.fill", "hammer.fill", "wrench.fill",
        "gamecontroller.fill", "music.note", "photo.fill", "video.fill",
        "message.fill", "envelope.fill", "globe", "book.fill",
        "graduationcap.fill", "paintbrush.fill", "camera.fill", "film.fill"
    ]

    init(category: CustomCategory, isPresented: Binding<Bool>) {
        self.category = category
        self._isPresented = isPresented
        self._categoryName = State(initialValue: category.displayName)
        self._selectedIcon = State(initialValue: category.icon)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(L("editCategory"))
                .font(.system(size: 18, weight: .semibold))

            TextField(L("categoryName"), text: $categoryName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)

            VStack(alignment: .leading, spacing: 10) {
                Text(L("selectIcon"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(44)), count: 5), spacing: 10) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Button(action: { selectedIcon = icon }) {
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedIcon == icon ? .white : .blue)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedIcon == icon ? Color.blue : Color.blue.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
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
        .padding(30)
        .frame(width: 320)
    }
}

// MARK: - App Selector Sheet
struct AppSelectorSheet: View {
    let category: CustomCategory
    @Binding var isPresented: Bool
    @ObservedObject var categoryManager = CategoryManager.shared
    @State private var searchText = ""
    @State private var apps: [AppItem] = []

    var filteredApps: [AppItem] {
        if searchText.isEmpty {
            return apps
        }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    Text(category.displayName)
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                TextField(L("searchApps"), text: $searchText)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(20)
            .background(Color(nsColor: NSColor.controlBackgroundColor).opacity(0.5))

            // App List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredApps) { app in
                        AppSelectionRow(app: app, category: category)
                    }
                }
                .padding(16)
            }

            // Footer
            HStack {
                Text(L("appsWillBeCategorized", category.displayName))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
                Button(L("done")) {
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(16)
            .background(Color(nsColor: NSColor.controlBackgroundColor).opacity(0.3))
        }
        .frame(width: 450, height: 500)
        .onAppear {
            apps = AppScanner.scanApplications()
        }
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
            HStack(spacing: 12) {
                Image(nsImage: app.icon)
                    .resizable()
                    .frame(width: 32, height: 32)

                Text(app.name)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: CustomCategory?
    let isSelected: Bool
    let action: () -> Void

    var title: String {
        category?.displayName ?? L("all")
    }

    var icon: String {
        category?.icon ?? "square.grid.2x2.fill"
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue.opacity(0.6) : Color.white.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Icon View
struct AppIconView: View {
    let app: AppItem
    let size: CGFloat
    let onTap: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(nsImage: app.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.3), radius: isHovered ? 10 : 5)
                    .scaleEffect(isHovered ? 1.12 : 1.0)

                Text(app.name)
                    .font(.system(size: size > 64 ? 13 : 11, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: size + 30)
                    .shadow(color: .black.opacity(0.5), radius: 2)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovered ? Color.white.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Folder Card View
struct FolderCardView: View {
    let folder: FolderGroup
    let iconSize: CGFloat
    let onTap: () -> Void
    @State private var isHovered = false
    @ObservedObject var localization = LocalizationManager.shared

    // Preview icon size - larger icons
    var previewIconSize: CGFloat {
        max(36, iconSize * 0.65)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // 2x2 Preview Grid - NO background
                LazyVGrid(columns: [GridItem(.fixed(previewIconSize)), GridItem(.fixed(previewIconSize))], spacing: 8) {
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

                // Folder Info
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: folder.icon)
                            .font(.system(size: 14))
                        Text(folder.title)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)

                    Text(L("appsCount", folder.count))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isHovered ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(isHovered ? 0.25 : 0.12), lineWidth: 1)
                    )
            )
            .scaleEffect(isHovered ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Folder Grid View
struct FolderGridView: View {
    let folders: [FolderGroup]
    let onFolderTap: (UUID) -> Void
    @ObservedObject var settings = LauncherSettings.shared

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: settings.gridSpacing + 10), count: calculateFolderColumns(width: geometry.size.width)),
                    spacing: settings.gridSpacing + 10
                ) {
                    ForEach(folders) { folder in
                        FolderCardView(folder: folder, iconSize: settings.iconSize) {
                            onFolderTap(folder.id)
                        }
                    }
                }
                .padding(.horizontal, 100)
                .padding(.vertical, 40)
            }
        }
    }

    // Auto calculate folder columns based on icon size
    func calculateFolderColumns(width: CGFloat) -> Int {
        let cardWidth = settings.iconSize * 2.2 + 60 // Approximate card width
        let availableWidth = width - 200
        return max(3, min(5, Int(availableWidth / cardWidth)))
    }
}

// MARK: - Folder Detail Overlay
struct FolderDetailOverlay: View {
    let folder: FolderGroup
    let apps: [AppItem]
    @Binding var searchQuery: String
    let onBack: () -> Void
    let onAppTap: (AppItem) -> Void
    @ObservedObject var settings = LauncherSettings.shared
    @ObservedObject var localization = LocalizationManager.shared

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Header
                HStack(spacing: 16) {
                    // Back Button
                    Button(action: onBack) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text(L("back"))
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)

                    // Folder Title
                    HStack(spacing: 10) {
                        Image(systemName: folder.icon)
                            .font(.system(size: 22))
                        Text(folder.title)
                            .font(.system(size: 24, weight: .bold))
                        Text("(\(apps.count))")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .foregroundColor(.white)

                    Spacer()

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))
                        TextField(L("searchThisCategory"), text: $searchQuery)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.12))
                    )
                    .frame(maxWidth: 300)
                }
                .padding(.horizontal, 80)
                .padding(.top, 80)

                // Apps Grid
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: settings.gridSpacing),
                                     count: calculateColumns(width: geometry.size.width - 160)),
                        spacing: settings.gridSpacing
                    ) {
                        ForEach(apps) { app in
                            AppIconView(app: app, size: settings.iconSize) {
                                onAppTap(app)
                            }
                        }
                    }
                    .padding(.horizontal, 80)
                    .padding(.vertical, 30)
                }

                // Bottom hint
                Text("\(L("hintEscBack"))  |  \(L("hintHotkey")): \(settings.hotkeyDescription)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 80)
            }
        }
        .background(
            Color.black.opacity(0.2)
                .ignoresSafeArea()
        )
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    func calculateColumns(width: CGFloat) -> Int {
        let itemWidth = settings.iconSize + 50
        let padding: CGFloat = 60
        let availableWidth = width - padding
        return max(4, Int(availableWidth / itemWidth))
    }
}

// MARK: - Main Launcher View
struct LauncherView: View {
    @ObservedObject private var viewModel = LauncherViewModel.shared
    @ObservedObject var settings = LauncherSettings.shared
    @ObservedObject var categoryManager = CategoryManager.shared
    @ObservedObject var localization = LocalizationManager.shared

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)
                    .ignoresSafeArea()

                Color.black.opacity(settings.backgroundOpacity)
                    .ignoresSafeArea()

                // Route-based content
                if settings.showCategories {
                    // Folder browsing mode
                    ZStack {
                        // Home view with folder cards
                        if viewModel.route == .home {
                            VStack(spacing: 16) {
                                // Top Bar
                                HStack {
                                    // Settings Button
                                    Button(action: { viewModel.showSettings.toggle() }) {
                                        Image(systemName: "gear")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(10)
                                            .background(Circle().fill(Color.white.opacity(0.1)))
                                    }
                                    .buttonStyle(.plain)

                                    // Category Manager Button
                                    Button(action: { viewModel.showCategoryManager.toggle() }) {
                                        Image(systemName: "folder.badge.gearshape")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(10)
                                            .background(Circle().fill(Color.white.opacity(0.1)))
                                    }
                                    .buttonStyle(.plain)

                                    Spacer()

                                    // Search Bar (searches folder names when at home)
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.white.opacity(0.7))
                                        TextField(L("searchCategoryOrApps"), text: $viewModel.searchText)
                                            .textFieldStyle(.plain)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.12))
                                    )
                                    .frame(maxWidth: 350)

                                    Spacer()

                                    // Refresh Button
                                    Button(action: { viewModel.refresh() }) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(10)
                                            .background(Circle().fill(Color.white.opacity(0.1)))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 80)
                                .padding(.top, 80)

                                // Display folder cards or search results
                                if viewModel.searchText.isEmpty {
                                    // Folder Grid
                                    FolderGridView(folders: viewModel.folderGroups) { folderId in
                                        viewModel.navigateToFolder(id: folderId)
                                    }
                                } else {
                                    // Search results - show apps matching search
                                    ScrollView {
                                        LazyVGrid(
                                            columns: Array(repeating: GridItem(.flexible(), spacing: settings.gridSpacing),
                                                         count: calculateColumns(width: geometry.size.width - 160)),
                                            spacing: settings.gridSpacing
                                        ) {
                                            ForEach(viewModel.filteredApps) { app in
                                                AppIconView(app: app, size: settings.iconSize) {
                                                    viewModel.launchApp(app)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 80)
                                        .padding(.vertical, 30)
                                    }
                                }

                                // Bottom hint
                                Text("\(L("hintEscClose"))  |  \(L("hintHotkey")): \(settings.hotkeyDescription)  |  \(L("hintClickCategory"))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.bottom, 80)
                            }
                            .transition(.opacity)
                        }

                        // Folder Detail view
                        if case .folderDetail = viewModel.route, let folder = viewModel.activeFolder {
                            FolderDetailOverlay(
                                folder: folder,
                                apps: viewModel.filteredFolderApps,
                                searchQuery: $viewModel.folderQuery,
                                onBack: { viewModel.navigateToHome() },
                                onAppTap: { app in viewModel.launchApp(app) }
                            )
                        }
                    }
                } else {
                    // Non-category mode - flat app list
                    VStack(spacing: 16) {
                        // Top Bar
                        HStack {
                            // Settings Button
                            Button(action: { viewModel.showSettings.toggle() }) {
                                Image(systemName: "gear")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(10)
                                    .background(Circle().fill(Color.white.opacity(0.1)))
                            }
                            .buttonStyle(.plain)

                            // Category Manager Button
                            Button(action: { viewModel.showCategoryManager.toggle() }) {
                                Image(systemName: "folder.badge.gearshape")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(10)
                                    .background(Circle().fill(Color.white.opacity(0.1)))
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.7))
                                TextField(L("searchApps"), text: $viewModel.searchText)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.12))
                            )
                            .frame(maxWidth: 350)

                            Spacer()

                            // Refresh Button
                            Button(action: { viewModel.refresh() }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(10)
                                    .background(Circle().fill(Color.white.opacity(0.1)))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 80)
                        .padding(.top, 80)

                        // Flat view
                        ScrollView {
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: settings.gridSpacing),
                                             count: calculateColumns(width: geometry.size.width - 160)),
                                spacing: settings.gridSpacing
                            ) {
                                ForEach(viewModel.filteredApps) { app in
                                    AppIconView(app: app, size: settings.iconSize) {
                                        viewModel.launchApp(app)
                                    }
                                }
                            }
                            .padding(.horizontal, 80)
                            .padding(.vertical, 30)
                        }

                        // Bottom hint
                        Text("\(L("hintEscClose"))  |  \(L("hintHotkey")): \(settings.hotkeyDescription)  |  \(L("hintClickSettings"))")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.bottom, 80)
                    }
                }

                // Settings Panel
                if viewModel.showSettings {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.showSettings = false
                        }

                    SettingsView(isPresented: $viewModel.showSettings)
                }

                // Category Manager Panel
                if viewModel.showCategoryManager {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.showCategoryManager = false
                        }

                    CategoryManagerView(isPresented: $viewModel.showCategoryManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    func calculateColumns(width: CGFloat) -> Int {
        let itemWidth = settings.iconSize + 50
        let padding: CGFloat = 60
        let availableWidth = width - padding
        return max(4, Int(availableWidth / itemWidth))
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

    func registerHotkey() {
        // Unregister existing
        if let hotKey = eventHotKey {
            UnregisterEventHotKey(hotKey)
            eventHotKey = nil
        }

        let settings = LauncherSettings.shared

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4C4E4348) // "LNCH"
        hotKeyID.id = 1

        var eventHotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            settings.hotkeyKeyCode,
            settings.hotkeyModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &eventHotKeyRef
        )

        if status == noErr {
            eventHotKey = eventHotKeyRef
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var statusItem: NSStatusItem?
    var directoryMonitor = DirectoryMonitor()

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

        // Monitor app directories for changes
        directoryMonitor.startMonitoring {
            LauncherViewModel.shared.refresh()
        }

        // Show window initially
        showWindow()
    }

    @objc func toggleWindow() {
        if let window = window, window.isVisible {
            window.orderOut(nil)
        } else {
            showWindow()
        }
    }

    @objc func showWindow() {
        if window == nil {
            guard let screen = NSScreen.main else { return }

            window = NSWindow(
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

        window?.makeKeyAndOrderFront(nil)
        window?.makeFirstResponder(window?.contentView)

        // Refresh app list to pick up newly installed apps
        LauncherViewModel.shared.refresh()

        // Reset to home state when showing window
        let viewModel = LauncherViewModel.shared
        viewModel.route = .home
        viewModel.folderQuery = ""
        viewModel.searchText = ""

        // Handle ESC key with multi-level navigation
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // ESC key
                let viewModel = LauncherViewModel.shared
                let settings = LauncherSettings.shared

                // Check if we're in folder browsing mode
                if settings.showCategories {
                    switch viewModel.route {
                    case .folderDetail:
                        // If in folder detail with search query, clear the query
                        if !viewModel.folderQuery.isEmpty {
                            viewModel.folderQuery = ""
                            return nil
                        }
                        // If no search query, go back to home
                        viewModel.navigateToHome()
                        return nil

                    case .home:
                        // If at home with search text, clear it
                        if !viewModel.searchText.isEmpty {
                            viewModel.searchText = ""
                            return nil
                        }
                        // Otherwise close the launcher
                        self.window?.orderOut(nil)
                        return nil
                    }
                } else {
                    // Non-folder mode: clear search or close
                    if !viewModel.searchText.isEmpty {
                        viewModel.searchText = ""
                        return nil
                    }
                    self.window?.orderOut(nil)
                    return nil
                }
            }
            return event
        }

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
