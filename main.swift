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
        self.backgroundOpacity = UserDefaults.standard.object(forKey: "backgroundOpacity") as? Double ?? 0.4
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
            0x7A: "F1", 0x78: "F2", 0x63: "F3", 0x76: "F4",
            0x60: "F5", 0x61: "F6", 0x62: "F7", 0x64: "F8",
            0x65: "F9", 0x6D: "F10", 0x67: "F11", 0x6F: "F12",
            0x31: "Space", 0x24: "Return", 0x30: "Tab"
        ]
        return keyMap[keyCode] ?? "Key\(keyCode)"
    }
}

// MARK: - App Category
enum AppCategory: String, CaseIterable {
    case productivity = "生產力工具"
    case development = "開發工具"
    case media = "影音媒體"
    case utilities = "系統工具"
    case social = "社交通訊"
    case games = "遊戲"
    case other = "其他"

    static func categorize(_ appName: String, path: String) -> AppCategory {
        let name = appName.lowercased()
        let pathLower = path.lowercased()

        // Development
        if name.contains("xcode") || name.contains("code") || name.contains("terminal") ||
           name.contains("git") || name.contains("docker") || name.contains("sublime") ||
           name.contains("visual studio") || name.contains("intellij") || name.contains("android") {
            return .development
        }

        // Media
        if name.contains("music") || name.contains("photo") || name.contains("video") ||
           name.contains("spotify") || name.contains("vlc") || name.contains("imovie") ||
           name.contains("final cut") || name.contains("garageband") || name.contains("quicktime") {
            return .media
        }

        // Social
        if name.contains("message") || name.contains("mail") || name.contains("slack") ||
           name.contains("discord") || name.contains("telegram") || name.contains("whatsapp") ||
           name.contains("zoom") || name.contains("teams") || name.contains("facetime") ||
           name.contains("line") || name.contains("wechat") {
            return .social
        }

        // Productivity
        if name.contains("word") || name.contains("excel") || name.contains("pages") ||
           name.contains("numbers") || name.contains("keynote") || name.contains("notion") ||
           name.contains("notes") || name.contains("reminder") || name.contains("calendar") ||
           name.contains("safari") || name.contains("chrome") || name.contains("firefox") {
            return .productivity
        }

        // Utilities
        if pathLower.contains("utilities") || name.contains("system") || name.contains("disk") ||
           name.contains("activity") || name.contains("console") || name.contains("finder") ||
           name.contains("setting") || name.contains("preference") {
            return .utilities
        }

        // Games
        if name.contains("game") || name.contains("steam") || name.contains("chess") ||
           pathLower.contains("games") {
            return .games
        }

        return .other
    }
}

// MARK: - App Model
class AppItem: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let path: String
    let icon: NSImage
    let category: AppCategory

    init(name: String, path: String, icon: NSImage) {
        self.name = name
        self.path = path
        self.icon = icon
        self.category = AppCategory.categorize(name, path: path)
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
    @Published var selectedCategory: AppCategory? = nil
    @Published var showSettings: Bool = false

    var filteredApps: [AppItem] {
        var result = apps

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var groupedApps: [(AppCategory, [AppItem])] {
        let filtered = filteredApps
        var grouped: [AppCategory: [AppItem]] = [:]

        for app in filtered {
            grouped[app.category, default: []].append(app)
        }

        return AppCategory.allCases.compactMap { category in
            guard let apps = grouped[category], !apps.isEmpty else { return nil }
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
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var settings = LauncherSettings.shared
    @Binding var isPresented: Bool
    @State private var isRecordingHotkey = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("設定")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(Color.white.opacity(0.1))

            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Icon Size
                    settingSection(title: "圖標大小", icon: "square.grid.2x2") {
                        HStack {
                            Text("\(Int(settings.iconSize))")
                                .foregroundColor(.white)
                                .frame(width: 40)
                            Slider(value: $settings.iconSize, in: 48...128, step: 8)
                                .tint(.blue)
                            Image(systemName: "app.fill")
                                .font(.system(size: settings.iconSize / 3))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    // Grid Spacing
                    settingSection(title: "間距", icon: "arrow.left.and.right") {
                        HStack {
                            Text("\(Int(settings.gridSpacing))")
                                .foregroundColor(.white)
                                .frame(width: 40)
                            Slider(value: $settings.gridSpacing, in: 10...60, step: 5)
                                .tint(.blue)
                        }
                    }

                    // Columns
                    settingSection(title: "每行數量", icon: "rectangle.split.3x1") {
                        Picker("", selection: $settings.columnsCount) {
                            Text("自動").tag(0)
                            ForEach(4...12, id: \.self) { count in
                                Text("\(count) 個").tag(count)
                            }
                        }
                        .pickerStyle(.segmented)
                        .colorMultiply(.blue)
                    }

                    // Background Opacity
                    settingSection(title: "背景透明度", icon: "circle.lefthalf.filled") {
                        HStack {
                            Text("\(Int(settings.backgroundOpacity * 100))%")
                                .foregroundColor(.white)
                                .frame(width: 50)
                            Slider(value: $settings.backgroundOpacity, in: 0.1...0.9, step: 0.1)
                                .tint(.blue)
                        }
                    }

                    // Show Categories
                    settingSection(title: "顯示分類", icon: "folder") {
                        Toggle("", isOn: $settings.showCategories)
                            .toggleStyle(.switch)
                            .tint(.blue)
                    }

                    // Hotkey
                    settingSection(title: "全域快捷鍵", icon: "command") {
                        HStack {
                            Text(settings.hotkeyDescription)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isRecordingHotkey ? Color.red.opacity(0.3) : Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(isRecordingHotkey ? Color.red : Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )

                            Button(isRecordingHotkey ? "取消" : "修改") {
                                isRecordingHotkey.toggle()
                                if isRecordingHotkey {
                                    startRecordingHotkey()
                                }
                            }
                            .foregroundColor(.blue)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(25)
            }
        }
        .frame(width: 450, height: 550)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    func settingSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
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

                // Re-register hotkey
                HotkeyManager.shared.registerHotkey()

                return nil
            }
            return event
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: AppCategory?
    let isSelected: Bool
    let action: () -> Void

    var title: String {
        category?.rawValue ?? "全部"
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
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
                    .padding(.horizontal, 30)
                    .padding(.top, 25)

                    // Category Filter
                    if settings.showCategories {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                CategoryButton(category: nil, isSelected: viewModel.selectedCategory == nil) {
                                    viewModel.selectedCategory = nil
                                }

                                ForEach(AppCategory.allCases, id: \.self) { category in
                                    CategoryButton(category: category, isSelected: viewModel.selectedCategory == category) {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                    }

                    // Apps Grid
                    ScrollView {
                        if settings.showCategories && viewModel.selectedCategory == nil && viewModel.searchText.isEmpty {
                            // Grouped view
                            LazyVStack(alignment: .leading, spacing: 30) {
                                ForEach(viewModel.groupedApps, id: \.0) { category, apps in
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text(category.rawValue)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.9))
                                            .padding(.leading, 10)

                                        LazyVGrid(
                                            columns: Array(repeating: GridItem(.flexible(), spacing: settings.gridSpacing),
                                                         count: calculateColumns(width: geometry.size.width)),
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
                            .padding(30)
                        } else {
                            // Flat view
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: settings.gridSpacing),
                                             count: calculateColumns(width: geometry.size.width)),
                                spacing: settings.gridSpacing
                            ) {
                                ForEach(viewModel.filteredApps) { app in
                                    AppIconView(app: app, size: settings.iconSize) {
                                        viewModel.launchApp(app)
                                    }
                                }
                            }
                            .padding(30)
                        }
                    }

                    // Bottom hint
                    Text("按 ESC 關閉  |  快捷鍵: \(settings.hotkeyDescription)  |  點擊 ⚙️ 開啟設定")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 15)
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
}

// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
