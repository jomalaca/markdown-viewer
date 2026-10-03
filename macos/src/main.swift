import AppKit
import WebKit
import UniformTypeIdentifiers

// ==============================================================================
// Markdown Viewer — Native macOS Host Application
// 100% Private, Local-First, Fast Native AppKit + WKWebView
// ==============================================================================

// MARK: - Local File Scheme Handler for Images & Media
class LocalFileSchemeHandler: NSObject, WKURLSchemeHandler {
    private let allowedImageExtensions: Set<String> = [
        "png", "jpg", "jpeg", "gif", "webp", "svg", "ico", "bmp", "avif", "tiff", "tif"
    ]

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(NSError(domain: "LocalFileSchemeHandler", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        let rawPath = url.path
        let filePath = (rawPath.removingPercentEncoding ?? rawPath)
        let fileURL = URL(fileURLWithPath: filePath).standardized
        let ext = fileURL.pathExtension.lowercased()

        // 1. Enforce strict image extension whitelist
        guard allowedImageExtensions.contains(ext) else {
            NSLog("LocalFileSchemeHandler: Blocked request for non-image file extension: \(ext)")
            let response = HTTPURLResponse(url: url, statusCode: 403, httpVersion: "HTTP/1.1", headerFields: [
                "Content-Type": "text/plain"
            ])!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(Data("Forbidden: Non-image file type".utf8))
            urlSchemeTask.didFinish()
            return
        }

        // 2. Block hidden / sensitive system files (.env, .ssh, etc.)
        let fileName = fileURL.lastPathComponent
        if fileName.hasPrefix(".") && !fileName.hasPrefix(".DS_Store") {
            NSLog("LocalFileSchemeHandler: Blocked request for hidden file: \(fileName)")
            let response = HTTPURLResponse(url: url, statusCode: 403, httpVersion: "HTTP/1.1", headerFields: [
                "Content-Type": "text/plain"
            ])!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didFinish()
            return
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            NSLog("LocalFileSchemeHandler: File not found at \(fileURL.path)")
            let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil)!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didFinish()
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let mimeType = UTType(filenameExtension: ext)?.preferredMIMEType ?? "image/\(ext)"

            let headers = [
                "Content-Type": mimeType,
                "Content-Length": String(data.count),
                "Cache-Control": "max-age=3600"
            ]

            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } catch {
            NSLog("LocalFileSchemeHandler error reading \(fileURL.path): \(error)")
            urlSchemeTask.didFailWithError(error)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // Nothing to cancel for instantaneous local disk reads
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate, NSMenuItemValidation {
    var window: NSWindow!
    var webView: WKWebView!
    var pendingFiles: [String] = []
    var openedFiles: Set<String> = []
    var isWebLoaded: Bool = false

    enum PendingSaveContinuation {
        case none
        case closeWindow
        case terminateApp
    }
    var pendingSaveContinuation: PendingSaveContinuation = .none

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set Dock and Application Switcher icon at runtime
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
           let iconImage = NSImage(contentsOf: iconURL) {
            NSApp.applicationIconImage = iconImage
        }
        setupMainMenu()
        setupWindow()
        loadWebContent()
    }

    // --- Window & WebView Setup ---
    func setupWindow() {
        let contentRect = NSRect(x: 100, y: 100, width: 1200, height: 800)
        window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Markdown Viewer"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.setFrameAutosaveName("MarkdownViewerMainWindow")

        // Configure WKWebView
        let config = WKWebViewConfiguration()
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        config.userContentController.add(self, name: "nativeApp")
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        config.setURLSchemeHandler(LocalFileSchemeHandler(), forURLScheme: "local-file")

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = window.contentView!
        contentView.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // --- Load Web Content ---
    func loadWebContent() {
        // Priority 1: Check inside App Bundle Resources
        if let bundleResource = Bundle.main.url(forResource: "index", withExtension: "html") {
            let resourceDir = Bundle.main.resourceURL ?? bundleResource.deletingLastPathComponent()
            webView.loadFileURL(bundleResource, allowingReadAccessTo: resourceDir)
            return
        }

        // Priority 2: Check current working directory or relative to binary (Dev/CLI mode)
        let cwd = FileManager.default.currentDirectoryPath
        let localURL = URL(fileURLWithPath: cwd).appendingPathComponent("index.html")
        if FileManager.default.fileExists(atPath: localURL.path) {
            webView.loadFileURL(localURL, allowingReadAccessTo: URL(fileURLWithPath: cwd))
            return
        }

        // Priority 3: Check app bundle ancestor directory
        var candidate = Bundle.main.bundleURL.deletingLastPathComponent()
        for _ in 0..<4 {
            let tryURL = candidate.appendingPathComponent("index.html")
            if FileManager.default.fileExists(atPath: tryURL.path) {
                webView.loadFileURL(tryURL, allowingReadAccessTo: candidate)
                return
            }
            candidate = candidate.deletingLastPathComponent()
        }

        NSLog("Warning: Could not locate index.html")
    }

    // --- File Handling: Terminal & Finder ('open -a Markdown Viewer <file>') ---
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        if isWebLoaded {
            for file in filenames {
                openMarkdownFile(file)
            }
        } else {
            pendingFiles.append(contentsOf: filenames)
        }
        sender.reply(toOpenOrPrint: .success)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isWebLoaded = true
        // Process any files that were queued before the web view completed loading
        for file in pendingFiles {
            openMarkdownFile(file)
        }
        pendingFiles.removeAll()
    }

    // --- External Link Handling: Open links in default browser instead of navigating webview ---
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
            if url.scheme == "http" || url.scheme == "https" || url.scheme == "mailto" {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }

    func openMarkdownFile(_ path: String) {
        let fileURL = URL(fileURLWithPath: path).standardized
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            NSLog("File does not exist: \(path)")
            return
        }

        openedFiles.insert(fileURL.path)

        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let title = fileURL.lastPathComponent

            // Safe JSON encoding
            let titleJSON = jsonString(from: title)
            let contentJSON = jsonString(from: content)
            let pathJSON = jsonString(from: fileURL.path)

            let script = "if (window.openDocumentFromHost) { window.openDocumentFromHost(\(titleJSON), \(contentJSON), \(pathJSON)); }"
            webView.evaluateJavaScript(script, completionHandler: { (_, error) in
                if let error = error {
                    NSLog("Error delivering document to webView: \(error)")
                }
            })
            window.title = "\(title) — Markdown Viewer"
            window.representedURL = fileURL
            window.isDocumentEdited = false
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } catch {
            NSLog("Failed to read file at \(path): \(error)")
        }
    }

    func jsonString(from string: String) -> String {
        if let data = try? JSONSerialization.data(withJSONObject: [string], options: []),
           let str = String(data: data, encoding: .utf8) {
            let start = str.index(after: str.startIndex)
            let end = str.index(before: str.endIndex)
            return String(str[start..<end])
        }
        return "\"\""
    }

    // --- JavaScript -> Native Swift Bridge ---
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any],
              let action = dict["action"] as? String else { return }

        switch action {
        case "saveFile":
            guard let content = dict["content"] as? String,
                  let tabId = dict["tabId"] as? String else { return }
            let existingPath = dict["filePath"] as? String
            let saveAs = dict["saveAs"] as? Bool ?? false
            let rawTitle = (dict["title"] as? String) ?? "Untitled.md"
            let hasKnownExt = rawTitle.hasSuffix(".md") || rawTitle.hasSuffix(".markdown") || rawTitle.hasSuffix(".json") || rawTitle.hasSuffix(".yaml") || rawTitle.hasSuffix(".yml") || rawTitle.hasSuffix(".txt")
            let title = hasKnownExt ? rawTitle : "\(rawTitle).md"

            let standardizedPath = existingPath.map { URL(fileURLWithPath: $0).standardized.path }
            let isVerifiedOpenedFile = standardizedPath.map { openedFiles.contains($0) } ?? false

            if let path = standardizedPath, !saveAs, !path.isEmpty && FileManager.default.fileExists(atPath: path) && isVerifiedOpenedFile {
                // Direct write to existing file on disk (strictly verified as opened in this session)
                do {
                    try content.write(toFile: path, atomically: true, encoding: .utf8)
                    openedFiles.insert(path)
                    let pathJSON = jsonString(from: path)
                    let titleJSON = jsonString(from: URL(fileURLWithPath: path).lastPathComponent)
                    let tabIdJSON = jsonString(from: tabId)
                    webView.evaluateJavaScript("window.onFileSavedFromHost?.(\(tabIdJSON), \(pathJSON), \(titleJSON));", completionHandler: nil)
                    window.representedURL = URL(fileURLWithPath: path)
                    window.isDocumentEdited = false
                    if pendingSaveContinuation != .none {
                        didFinishSavingAllDirtyDocuments(success: true)
                    }
                } catch {
                    NSLog("Failed to direct-save to \(path): \(error)")
                    if pendingSaveContinuation != .none {
                        didFinishSavingAllDirtyDocuments(success: false)
                    }
                }
            } else {
                // Show native NSSavePanel
                let panel = NSSavePanel()
                panel.canCreateDirectories = true
                panel.nameFieldStringValue = title
                var saveTypes: [UTType] = [
                    UTType(filenameExtension: "md") ?? .plainText,
                    .json,
                    .plainText
                ]
                if let yamlType = UTType(filenameExtension: "yaml") { saveTypes.append(yamlType) }
                if let ymlType = UTType(filenameExtension: "yml") { saveTypes.append(ymlType) }
                panel.allowedContentTypes = saveTypes
                if let path = standardizedPath, !path.isEmpty {
                    panel.directoryURL = URL(fileURLWithPath: path).deletingLastPathComponent()
                }
                if panel.runModal() == .OK, let targetURL = panel.url {
                    let targetPath = targetURL.standardized.path
                    do {
                        try content.write(toFile: targetPath, atomically: true, encoding: .utf8)
                        openedFiles.insert(targetPath)
                        let pathJSON = jsonString(from: targetPath)
                        let titleJSON = jsonString(from: targetURL.lastPathComponent)
                        let tabIdJSON = jsonString(from: tabId)
                        webView.evaluateJavaScript("window.onFileSavedFromHost?.(\(tabIdJSON), \(pathJSON), \(titleJSON));", completionHandler: nil)
                        window.representedURL = targetURL
                        window.title = "\(targetURL.lastPathComponent) — Markdown Viewer"
                        window.isDocumentEdited = false
                        if pendingSaveContinuation != .none {
                            didFinishSavingAllDirtyDocuments(success: true)
                        }
                    } catch {
                        NSLog("NSSavePanel save failed: \(error)")
                        if pendingSaveContinuation != .none {
                            didFinishSavingAllDirtyDocuments(success: false)
                        }
                    }
                } else {
                    if pendingSaveContinuation != .none {
                        didFinishSavingAllDirtyDocuments(success: false)
                    }
                }
            }

        case "saveMultipleFiles":
            guard let tabs = dict["tabs"] as? [[String: Any]] else {
                didFinishSavingAllDirtyDocuments(success: true)
                return
            }
            var allSucceeded = true
            for tab in tabs {
                guard let content = tab["content"] as? String,
                      let tabId = tab["id"] as? String else { continue }
                let existingPath = tab["filePath"] as? String
                let rawTitle = (tab["title"] as? String) ?? "Untitled.md"
                let hasKnownExt = rawTitle.hasSuffix(".md") || rawTitle.hasSuffix(".markdown") || rawTitle.hasSuffix(".json") || rawTitle.hasSuffix(".yaml") || rawTitle.hasSuffix(".yml") || rawTitle.hasSuffix(".txt")
                let title = hasKnownExt ? rawTitle : "\(rawTitle).md"

                let standardizedPath = existingPath.map { URL(fileURLWithPath: $0).standardized.path }
                let isVerifiedOpenedFile = standardizedPath.map { openedFiles.contains($0) } ?? false

                if let path = standardizedPath, !path.isEmpty && FileManager.default.fileExists(atPath: path) && isVerifiedOpenedFile {
                    do {
                        try content.write(toFile: path, atomically: true, encoding: .utf8)
                        openedFiles.insert(path)
                        let pathJSON = jsonString(from: path)
                        let titleJSON = jsonString(from: URL(fileURLWithPath: path).lastPathComponent)
                        let tabIdJSON = jsonString(from: tabId)
                        webView.evaluateJavaScript("window.onFileSavedFromHost?.(\(tabIdJSON), \(pathJSON), \(titleJSON));", completionHandler: nil)
                    } catch {
                        NSLog("Failed to direct-save dirty tab to \(path): \(error)")
                        allSucceeded = false
                        break
                    }
                } else {
                    let panel = NSSavePanel()
                    panel.canCreateDirectories = true
                    panel.nameFieldStringValue = title
                    var saveTypes: [UTType] = [
                        UTType(filenameExtension: "md") ?? .plainText,
                        .json,
                        .plainText
                    ]
                    if let yamlType = UTType(filenameExtension: "yaml") { saveTypes.append(yamlType) }
                    if let ymlType = UTType(filenameExtension: "yml") { saveTypes.append(ymlType) }
                    panel.allowedContentTypes = saveTypes
                    if panel.runModal() == .OK, let targetURL = panel.url {
                        do {
                            try content.write(to: targetURL, atomically: true, encoding: .utf8)
                            openedFiles.insert(targetURL.path)
                            let pathJSON = jsonString(from: targetURL.path)
                            let titleJSON = jsonString(from: targetURL.lastPathComponent)
                            let tabIdJSON = jsonString(from: tabId)
                            webView.evaluateJavaScript("window.onFileSavedFromHost?.(\(tabIdJSON), \(pathJSON), \(titleJSON));", completionHandler: nil)
                        } catch {
                            NSLog("Failed to save dirty tab via NSSavePanel: \(error)")
                            allSucceeded = false
                            break
                        }
                    } else {
                        // User cancelled saving one of the tabs
                        allSucceeded = false
                        break
                    }
                }
            }
            didFinishSavingAllDirtyDocuments(success: allSucceeded)

        case "allDirtyTabsSaved":
            didFinishSavingAllDirtyDocuments(success: true)

        case "exportHtml":
            guard let content = dict["content"] as? String else { return }
            let title = (dict["title"] as? String) ?? "Document"
            let panel = NSSavePanel()
            panel.canCreateDirectories = true
            panel.nameFieldStringValue = "\(title).html"
            panel.allowedContentTypes = [
                UTType.html
            ]
            if panel.runModal() == .OK, let targetURL = panel.url {
                do {
                    try content.write(to: targetURL, atomically: true, encoding: .utf8)
                } catch {
                    NSLog("Export HTML failed: \(error)")
                }
            }

        case "print":
            let printInfo = NSPrintInfo.shared
            let printOp = webView.printOperation(with: printInfo)
            printOp.run()

        case "openFileDialog":
            showOpenPanel()

        case "setTitle":
            if let title = dict["title"] as? String {
                window.title = "\(title) — Markdown Viewer"
            }

        case "setDocumentEdited":
            if let isEdited = dict["isEdited"] as? Bool {
                window.isDocumentEdited = isEdited
            }

        case "activeTabChanged":
            if let title = dict["title"] as? String {
                window.title = "\(title) — Markdown Viewer"
            }
            if let path = dict["filePath"] as? String, !path.isEmpty {
                window.representedURL = URL(fileURLWithPath: path)
            } else {
                window.representedURL = nil
            }

        case "reloadTabFromFile":
            guard let path = dict["filePath"] as? String,
                  let tabId = dict["tabId"] as? String,
                  FileManager.default.fileExists(atPath: path) else { return }
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let tabIdJSON = jsonString(from: tabId)
                let contentJSON = jsonString(from: content)
                let pathJSON = jsonString(from: path)
                webView.evaluateJavaScript("window.updateTabContentFromFile?.(\(tabIdJSON), \(contentJSON), \(pathJSON));", completionHandler: nil)
            } catch {
                NSLog("Failed to reload tab \(tabId) from file \(path): \(error)")
            }

        default:
            break
        }
    }

    // --- Native Open File Dialog ---
    @objc func showOpenPanel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        var openTypes: [UTType] = [
            .text,
            .plainText,
            .json,
            UTType(filenameExtension: "md") ?? .text,
            UTType(filenameExtension: "markdown") ?? .text
        ]
        if let yamlType = UTType(filenameExtension: "yaml") { openTypes.append(yamlType) }
        if let ymlType = UTType(filenameExtension: "yml") { openTypes.append(ymlType) }
        panel.allowedContentTypes = openTypes

        if panel.runModal() == .OK {
            for url in panel.urls {
                openMarkdownFile(url.path)
            }
        }
    }

    // --- Native Menus ---
    func setupMainMenu() {
        let mainMenu = NSMenu()

        // 1. App Menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: "Markdown Viewer")
        appMenu.addItem(withTitle: "About Markdown Viewer", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        let settingsItem = appMenu.addItem(withTitle: "Settings…", action: #selector(menuOpenSettings), keyEquivalent: ",")
        settingsItem.target = self
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Hide Markdown Viewer", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        let hideOthersItem = appMenu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        hideOthersItem.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        let quitItem = appMenu.addItem(withTitle: "Quit Markdown Viewer", action: #selector(menuQuit(_:)), keyEquivalent: "q")
        quitItem.target = self
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // 2. File Menu
        let fileMenuItem = NSMenuItem()
        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(withTitle: "New Tab", action: #selector(menuNewTab), keyEquivalent: "t")
        fileMenu.addItem(withTitle: "Open…", action: #selector(showOpenPanel), keyEquivalent: "o")
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "Close Tab", action: #selector(menuCloseTab), keyEquivalent: "w")
        let closeWinItem = fileMenu.addItem(withTitle: "Close Window", action: #selector(menuCloseWindow(_:)), keyEquivalent: "w")
        closeWinItem.keyEquivalentModifierMask = [.command, .shift]
        closeWinItem.target = self
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "Save", action: #selector(menuSaveFile), keyEquivalent: "s")
        let saveAsItem = fileMenu.addItem(withTitle: "Save As…", action: #selector(menuSaveFileAs), keyEquivalent: "s")
        saveAsItem.keyEquivalentModifierMask = [.command, .shift]
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "Export Standalone HTML…", action: #selector(menuExportHtml), keyEquivalent: "e")
        fileMenu.addItem(withTitle: "Print…", action: #selector(menuPrint), keyEquivalent: "p")
        fileMenuItem.submenu = fileMenu
        mainMenu.addItem(fileMenuItem)

        // 3. Edit Menu — Native Undo/Redo & Clipboard
        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        let undoItem = editMenu.addItem(withTitle: "Undo", action: #selector(menuUndo(_:)), keyEquivalent: "z")
        undoItem.target = self
        let redoItem = editMenu.addItem(withTitle: "Redo", action: #selector(menuRedo(_:)), keyEquivalent: "z")
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        redoItem.target = self
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenu.addItem(NSMenuItem.separator())
        let findMenuItem = NSMenuItem(title: "Find", action: nil, keyEquivalent: "")
        let findMenu = NSMenu(title: "Find")
        let findItem = findMenu.addItem(withTitle: "Find…", action: #selector(menuFind), keyEquivalent: "f")
        findItem.target = self
        let findAndReplaceItem = findMenu.addItem(withTitle: "Find and Replace…", action: #selector(menuFindAndReplace), keyEquivalent: "f")
        findAndReplaceItem.keyEquivalentModifierMask = [.command, .option]
        findAndReplaceItem.target = self
        let findNextItem = findMenu.addItem(withTitle: "Find Next", action: #selector(menuFindNext), keyEquivalent: "g")
        findNextItem.target = self
        let findPrevItem = findMenu.addItem(withTitle: "Find Previous", action: #selector(menuFindPrevious), keyEquivalent: "g")
        findPrevItem.keyEquivalentModifierMask = [.command, .shift]
        findPrevItem.target = self
        let useSelectionItem = findMenu.addItem(withTitle: "Use Selection for Find", action: #selector(menuUseSelectionForFind), keyEquivalent: "e")
        useSelectionItem.target = self
        findMenuItem.submenu = findMenu
        editMenu.addItem(findMenuItem)
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        // 4. View Menu
        let viewMenuItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        let editorItem = viewMenu.addItem(withTitle: "Editor Only", action: #selector(menuViewEditor), keyEquivalent: "e")
        editorItem.keyEquivalentModifierMask = [.command, .shift]
        let splitItem = viewMenu.addItem(withTitle: "Split View", action: #selector(menuViewSplit), keyEquivalent: "d")
        splitItem.keyEquivalentModifierMask = [.command, .shift]
        let previewItem = viewMenu.addItem(withTitle: "Preview Only", action: #selector(menuViewPreview), keyEquivalent: "v")
        previewItem.keyEquivalentModifierMask = [.command, .shift]
        viewMenu.addItem(NSMenuItem.separator())
        let outlineItem = viewMenu.addItem(withTitle: "Toggle Outline", action: #selector(menuToggleOutline), keyEquivalent: "o")
        outlineItem.keyEquivalentModifierMask = [.command, .shift]
        viewMenu.addItem(NSMenuItem.separator())
        viewMenu.addItem(withTitle: "Actual Size", action: #selector(menuResetZoom), keyEquivalent: "0")
        viewMenu.addItem(withTitle: "Zoom In", action: #selector(menuZoomIn), keyEquivalent: "=")
        viewMenu.addItem(withTitle: "Zoom Out", action: #selector(menuZoomOut), keyEquivalent: "-")
        viewMenu.addItem(NSMenuItem.separator())
        let fullScreenItem = viewMenu.addItem(withTitle: "Toggle Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        fullScreenItem.keyEquivalentModifierMask = [.command, .control]
        viewMenuItem.submenu = viewMenu
        mainMenu.addItem(viewMenuItem)

        // 5. Window Menu
        let windowMenuItem = NSMenuItem()
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        windowMenu.addItem(NSMenuItem.separator())
        let nextTabItem = windowMenu.addItem(withTitle: "Show Next Tab", action: #selector(menuNextTab), keyEquivalent: "\t")
        nextTabItem.keyEquivalentModifierMask = [.control]
        let prevTabItem = windowMenu.addItem(withTitle: "Show Previous Tab", action: #selector(menuPrevTab), keyEquivalent: "\t")
        prevTabItem.keyEquivalentModifierMask = [.control, .shift]
        windowMenu.addItem(NSMenuItem.separator())
        for i in 1...8 {
            windowMenu.addItem(withTitle: "Select Tab \(i)", action: #selector(menuSelectTab(_:)), keyEquivalent: "\(i)")
        }
        windowMenu.addItem(withTitle: "Select Last Tab", action: #selector(menuSelectTab(_:)), keyEquivalent: "9")
        windowMenu.addItem(NSMenuItem.separator())
        windowMenu.addItem(withTitle: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")
        windowMenuItem.submenu = windowMenu
        mainMenu.addItem(windowMenuItem)

        NSApp.mainMenu = mainMenu
    }

    // Menu Actions forwarded to JavaScript & Native Bridge
    @objc func menuOpenSettings() { webView.evaluateJavaScript("window.openSettingsModal?.('tab-editor');", completionHandler: nil) }
    @objc func menuNewTab() { webView.evaluateJavaScript("document.getElementById('new-tab-btn')?.click()", completionHandler: nil) }
    @objc func menuCloseTab() { webView.evaluateJavaScript("document.querySelector('.tab-item.active .tab-close')?.click()", completionHandler: nil) }
    @objc func menuCloseWindow(_ sender: Any?) {
        window.performClose(sender)
    }
    @objc func menuQuit(_ sender: Any?) {
        NSApp.terminate(sender)
    }
    @objc func menuSaveFile() { webView.evaluateJavaScript("window.saveDocumentFromHost?.(false);", completionHandler: nil) }
    @objc func menuSaveFileAs() { webView.evaluateJavaScript("window.saveDocumentFromHost?.(true);", completionHandler: nil) }
    @objc func menuExportHtml() { webView.evaluateJavaScript("window.exportHtmlFromHost?.();", completionHandler: nil) }
    @objc func menuPrint() { webView.evaluateJavaScript("window.print()", completionHandler: nil) }
    @objc func menuViewEditor() { webView.evaluateJavaScript("document.getElementById('view-mode-editor')?.click()", completionHandler: nil) }
    @objc func menuViewSplit() { webView.evaluateJavaScript("document.getElementById('view-mode-split')?.click()", completionHandler: nil) }
    @objc func menuViewPreview() { webView.evaluateJavaScript("document.getElementById('view-mode-preview')?.click()", completionHandler: nil) }
    @objc func menuToggleOutline() { webView.evaluateJavaScript("document.getElementById('toggle-sidebar-btn')?.click()", completionHandler: nil) }

    @objc func menuNextTab() { webView.evaluateJavaScript("window.cycleTab?.(1);", completionHandler: nil) }
    @objc func menuPrevTab() { webView.evaluateJavaScript("window.cycleTab?.(-1);", completionHandler: nil) }
    @objc func menuSelectTab(_ sender: NSMenuItem) {
        if let key = sender.keyEquivalent.first, let num = Int(String(key)) {
            let idx = (num == 9) ? -1 : (num - 1)
            webView.evaluateJavaScript("window.selectTabByIndex?.(\(idx));", completionHandler: nil)
        }
    }

    @objc func menuUndo(_ sender: Any?) {
        webView.evaluateJavaScript("window.editorUndo ? window.editorUndo() : document.execCommand('undo');", completionHandler: nil)
    }

    @objc func menuRedo(_ sender: Any?) {
        webView.evaluateJavaScript("window.editorRedo ? window.editorRedo() : document.execCommand('redo');", completionHandler: nil)
    }

    @objc func menuFind() { webView.evaluateJavaScript("window.openFindBar?.(false);", completionHandler: nil) }
    @objc func menuFindAndReplace() { webView.evaluateJavaScript("window.openFindBar?.(true);", completionHandler: nil) }
    @objc func menuFindNext() { webView.evaluateJavaScript("window.findNext?.();", completionHandler: nil) }
    @objc func menuFindPrevious() { webView.evaluateJavaScript("window.findPrevious?.();", completionHandler: nil) }
    @objc func menuUseSelectionForFind() { webView.evaluateJavaScript("window.useSelectionForFind?.();", completionHandler: nil) }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if window.isDocumentEdited {
            let alert = NSAlert()
            alert.messageText = "Do you want to save changes before closing?"
            alert.informativeText = "Your changes will be lost if you don't save them."
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Don't Save")
            alert.alertStyle = .warning

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                pendingSaveContinuation = .closeWindow
                saveAllDirtyDocuments()
                return false
            } else if response == .alertSecondButtonReturn {
                pendingSaveContinuation = .none
                return false
            } else {
                pendingSaveContinuation = .none
                window.isDocumentEdited = false
                return true
            }
        }
        return true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if window != nil && window.isDocumentEdited {
            let alert = NSAlert()
            alert.messageText = "Quit Markdown Viewer?"
            alert.informativeText = "You have unsaved documents. Your changes will be lost if you don't save them."
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Don't Save")
            alert.alertStyle = .warning

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                pendingSaveContinuation = .terminateApp
                saveAllDirtyDocuments()
                return .terminateCancel
            } else if response == .alertSecondButtonReturn {
                pendingSaveContinuation = .none
                return .terminateCancel
            } else {
                pendingSaveContinuation = .none
                window.isDocumentEdited = false
                return .terminateNow
            }
        }
        return .terminateNow
    }

    func saveAllDirtyDocuments() {
        webView.evaluateJavaScript("window.saveAllDirtyDocumentsFromHost ? window.saveAllDirtyDocumentsFromHost() : window.saveDocumentFromHost?.(false);", completionHandler: nil)
    }

    func didFinishSavingAllDirtyDocuments(success: Bool) {
        guard success else {
            pendingSaveContinuation = .none
            return
        }

        window.isDocumentEdited = false

        let continuation = pendingSaveContinuation
        pendingSaveContinuation = .none

        switch continuation {
        case .closeWindow:
            window.close()
        case .terminateApp:
            NSApp.terminate(nil)
        case .none:
            break
        }
    }

    @objc func menuZoomIn() {
        webView.pageZoom += 0.1
    }
    @objc func menuZoomOut() {
        webView.pageZoom = max(0.5, webView.pageZoom - 0.1)
    }
    @objc func menuResetZoom() {
        webView.pageZoom = 1.0
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// Entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
