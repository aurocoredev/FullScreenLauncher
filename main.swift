import Cocoa
import SwiftUI
import Carbon.HIToolbox

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
    @Published var columnsCount: Int {
        didSet { UserDefaults.standard.set(columnsCount, forKey: "columnsCount") }
    }
    @Published var hotkeyKeyCode: UInt32 {
        didSet { UserDefaults.standard.set(hotkeyKeyCode, forKey: "hotkeyKeyCode") }
    }
    @Published var hotkeyModifiers: UInt32 {
        didSet { UserDefaults.standard.set(hotkeyModifiers, forKey: "hotkeyModifiers") }
    }

    init() {
        self.iconSize = UserDefaults.standard.object(forKey: "iconSize") as? CGFloat ?? 64
        self.gridSpacing = UserDefaults.standard.object(forKey: "gridSpacing") as? CGFloat ?? 25
        self.showCategories = UserDefaults.standard.object(forKey: "showCategories") as? Bool ?? true
        self.backgroundOpacity = UserDefaults.standard.object(forKey: "backgroundOpacity") as? Double ?? 0.6
        self.columnsCount = UserDefaults.standard.object(forKey: "columnsCount") as? Int ?? 0  // 0 = auto
        self.hotkeyKeyCode = UserDefaults.standard.object(forKey: "hotkeyKeyCode") as? UInt32 ?? 0x7A  // F1
        self.hotkeyModifiers = UserDefaults.standard.object(forKey: "hotkeyModifiers") as? UInt32 ?? UInt32(cmdKey | optionKey)
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

    init(id: UUID = UUID(), name: String, icon: String = "folder.fill", appPaths: [String] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.appPaths = appPaths
    }
}

// MARK: - Category Manager
class CategoryManager: ObservableObject {
    static let shared = CategoryManager()

    @Published var categories: [CustomCategory] = []

    private let defaultCategories: [CustomCategory] = [
        CustomCategory(name: "生產力工具", icon: "briefcase.fill"),
        CustomCategory(name: "開發工具", icon: "hammer.fill"),
        CustomCategory(name: "影音媒體", icon: "play.circle.fill"),
        CustomCategory(name: "系統工具", icon: "gearshape.2.fill"),
        CustomCategory(name: "社交通訊", icon: "message.fill"),
        CustomCategory(name: "遊戲", icon: "gamecontroller.fill"),
        CustomCategory(name: "其他", icon: "square.grid.2x2.fill")
    ]

    private let saveKey = "customCategories"
    private let appCategoryMapKey = "appCategoryMap"

    // 應用程式路徑 -> 分類ID 的映射
    @Published var appCategoryMap: [String: UUID] = [:]

    init() {
        loadCategories()
        loadAppCategoryMap()
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

    private func autoCategorizePapp(appName: String, path: String) -> CustomCategory? {
        let name = appName.lowercased()
        let pathLower = path.lowercased()

        // Development
        if name.contains("xcode") || name.contains("code") || name.contains("terminal") ||
           name.contains("git") || name.contains("docker") || name.contains("sublime") ||
           name.contains("visual studio") || name.contains("intellij") || name.contains("android") {
            return categories.first { $0.name == "開發工具" }
        }

        // Media
        if name.contains("music") || name.contains("photo") || name.contains("video") ||
           name.contains("spotify") || name.contains("vlc") || name.contains("imovie") ||
           name.contains("final cut") || name.contains("garageband") || name.contains("quicktime") {
            return categories.first { $0.name == "影音媒體" }
        }

        // Social
        if name.contains("message") || name.contains("mail") || name.contains("slack") ||
           name.contains("discord") || name.contains("telegram") || name.contains("whatsapp") ||
           name.contains("zoom") || name.contains("teams") || name.contains("facetime") ||
           name.contains("line") || name.contains("wechat") {
            return categories.first { $0.name == "社交通訊" }
        }

        // Productivity
        if name.contains("word") || name.contains("excel") || name.contains("pages") ||
           name.contains("numbers") || name.contains("keynote") || name.contains("notion") ||
           name.contains("notes") || name.contains("reminder") || name.contains("calendar") ||
           name.contains("safari") || name.contains("chrome") || name.contains("firefox") {
            return categories.first { $0.name == "生產力工具" }
        }

        // Utilities
        if pathLower.contains("utilities") || name.contains("system") || name.contains("disk") ||
           name.contains("activity") || name.contains("console") || name.contains("finder") ||
           name.contains("setting") || name.contains("preference") {
            return categories.first { $0.name == "系統工具" }
        }

        // Games
        if name.contains("game") || name.contains("steam") || name.contains("chess") ||
           pathLower.contains("games") {
            return categories.first { $0.name == "遊戲" }
        }

        return categories.first { $0.name == "其他" }
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

// MARK: - ViewModel
class LauncherViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: CustomCategory? = nil
    @Published var showSettings: Bool = false
    @Published var showCategoryManager: Bool = false

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

    init() {
        apps = AppScanner.scanApplications()
    }

    func launchApp(_ app: AppItem) {
        NSWorkspace.shared.open(URL(fileURLWithPath: app.path))
        NSApplication.shared.hide(nil)
    }

    func refresh() {
        apps = AppScanner.scanApplications()
        objectWillChange.send()
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var settings = LauncherSettings.shared
    @Binding var isPresented: Bool
    @State private var isRecordingHotkey = false

    // Animation triggers
    @State private var iconSizeBounce = 0
    @State private var spacingBounce = 0
    @State private var columnsBounce = 0
    @State private var opacityBounce = 0
    @State private var categoryBounce = 0
    @State private var hotkeyBounce = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header - 固定在頂部
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .symbolEffect(.rotate, value: isPresented)
                Text("設定")
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
                        title: "圖標大小",
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
                        title: "間距",
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

                    // Columns
                    AnimatedSettingSection(
                        title: "每行數量",
                        icon: "rectangle.split.3x1.fill",
                        animationTrigger: columnsBounce
                    ) {
                        Picker("", selection: $settings.columnsCount) {
                            Text("自動").tag(0)
                            ForEach(4...12, id: \.self) { count in
                                Text("\(count) 個").tag(count)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: settings.columnsCount) { _, _ in
                            columnsBounce += 1
                        }
                    }

                    // Background Opacity
                    AnimatedSettingSection(
                        title: "背景深度",
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
                        title: "顯示分類",
                        icon: settings.showCategories ? "folder.fill" : "folder",
                        animationTrigger: categoryBounce
                    ) {
                        Toggle("依類別分組顯示應用程式", isOn: $settings.showCategories)
                            .toggleStyle(.switch)
                            .tint(.orange)
                            .onChange(of: settings.showCategories) { _, _ in
                                categoryBounce += 1
                            }
                    }

                    // Hotkey
                    AnimatedSettingSection(
                        title: "全域快捷鍵",
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
                                    Text(isRecordingHotkey ? "取消" : "修改")
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

                    Spacer(minLength: 10)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .frame(maxHeight: 480)
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
                Text("分類管理")
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
                            Text("新增分類")
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
                            Text("重置為預設分類")
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

// MARK: - Category Row View
struct CategoryRowView: View {
    let category: CustomCategory
    let onEdit: () -> Void
    let onManageApps: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false
    @State private var appCount: Int = 0
    @ObservedObject var categoryManager = CategoryManager.shared

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
                Text(category.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(appCount) 個應用程式")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isHovered {
                HStack(spacing: 8) {
                    Button(action: onManageApps) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Circle().fill(Color.blue.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                    .help("管理應用程式")

                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                            .padding(8)
                            .background(Circle().fill(Color.orange.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                    .help("編輯分類")

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Circle().fill(Color.red.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                    .help("刪除分類")
                }
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
            Text("新增分類")
                .font(.system(size: 18, weight: .semibold))

            TextField("分類名稱", text: $categoryName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)

            VStack(alignment: .leading, spacing: 10) {
                Text("選擇圖標")
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
                Button("取消") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Button("新增") {
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
        self._categoryName = State(initialValue: category.name)
        self._selectedIcon = State(initialValue: category.icon)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("編輯分類")
                .font(.system(size: 18, weight: .semibold))

            TextField("分類名稱", text: $categoryName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)

            VStack(alignment: .leading, spacing: 10) {
                Text("選擇圖標")
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
                Button("取消") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Button("儲存") {
                    if !categoryName.isEmpty {
                        var updatedCategory = category
                        updatedCategory.name = categoryName
                        updatedCategory.icon = selectedIcon
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
                    Text(category.name)
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                TextField("搜尋應用程式...", text: $searchText)
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
                Text("勾選的應用程式會歸類到「\(category.name)」")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
                Button("完成") {
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
        category?.name ?? "全部"
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

// MARK: - Main Launcher View
struct LauncherView: View {
    @StateObject private var viewModel = LauncherViewModel()
    @ObservedObject var settings = LauncherSettings.shared
    @ObservedObject var categoryManager = CategoryManager.shared

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)
                    .ignoresSafeArea()

                Color.black.opacity(settings.backgroundOpacity)
                    .ignoresSafeArea()

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
                            TextField("搜尋應用程式...", text: $viewModel.searchText)
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

                    // Category Filter
                    if settings.showCategories {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                CategoryButton(category: nil, isSelected: viewModel.selectedCategory == nil) {
                                    viewModel.selectedCategory = nil
                                }

                                ForEach(categoryManager.categories) { category in
                                    CategoryButton(category: category, isSelected: viewModel.selectedCategory?.id == category.id) {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal, 80)
                        }
                    }

                    // Apps Grid
                    ScrollView {
                        if settings.showCategories && viewModel.selectedCategory == nil && viewModel.searchText.isEmpty {
                            // Grouped view
                            LazyVStack(alignment: .leading, spacing: 30) {
                                ForEach(viewModel.groupedApps, id: \.0.id) { category, apps in
                                    VStack(alignment: .leading, spacing: 15) {
                                        HStack(spacing: 10) {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 16))
                                            Text(category.name)
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding(.leading, 10)

                                        LazyVGrid(
                                            columns: Array(repeating: GridItem(.flexible(), spacing: settings.gridSpacing),
                                                         count: calculateColumns(width: geometry.size.width - 160)),
                                            spacing: settings.gridSpacing
                                        ) {
                                            ForEach(apps) { app in
                                                AppIconView(app: app, size: settings.iconSize) {
                                                    viewModel.launchApp(app)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 80)
                            .padding(.vertical, 30)
                        } else {
                            // Flat view
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
                    Text("按 ESC 關閉  |  快捷鍵: \(settings.hotkeyDescription)  |  點擊 ⚙️ 開啟設定")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 80)
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
        if settings.columnsCount > 0 {
            return settings.columnsCount
        }
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

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "square.grid.3x3.fill", accessibilityDescription: "Launcher")
            button.action = #selector(toggleWindow)
        }

        // Setup menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "開啟啟動器", action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "結束", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
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

        // Handle ESC key
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // ESC key
                self.window?.orderOut(nil)
                return nil
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
