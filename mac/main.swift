// Touch Type Trainer: a small macOS window around web/index.html.
import Cocoa
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    var window: NSWindow!
    var web: WKWebView!

    func applicationDidFinishLaunching(_ note: Notification) {
        buildMenu()
        web = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        web.navigationDelegate = self
        web.setValue(false, forKey: "drawsBackground")
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1180, height: 860),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "Touch Type Trainer"
        window.backgroundColor = .black
        window.appearance = NSAppearance(named: .darkAqua)
        window.minSize = NSSize(width: 380, height: 520)
        window.contentView = web
        window.center()
        window.setFrameAutosaveName("TrainerMain")
        window.makeKeyAndOrderFront(nil)
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        let z = UserDefaults.standard.double(forKey: "zoom")
        if z > 0 { web.pageZoom = CGFloat(z) }
        NSApp.activate(ignoringOtherApps: true)
    }

    // Keep keyboard focus in the page so typing works straight away.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { window.makeFirstResponder(web) }
    func applicationDidBecomeActive(_ note: Notification) { if window != nil { window.makeFirstResponder(web) } }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    @objc func zoomIn(_ sender: Any?) { setZoom(web.pageZoom * 1.1) }
    @objc func zoomOut(_ sender: Any?) { setZoom(web.pageZoom / 1.1) }
    @objc func zoomReset(_ sender: Any?) { setZoom(1.0) }
    func setZoom(_ z: CGFloat) {
        let v = min(3.0, max(0.5, z))
        web.pageZoom = v
        UserDefaults.standard.set(Double(v), forKey: "zoom")
    }

    func buildMenu() {
        let main = NSMenu()
        let appItem = NSMenuItem(); main.addItem(appItem)
        let app = NSMenu()
        app.addItem(withTitle: "About Touch Type Trainer", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        app.addItem(.separator())
        app.addItem(withTitle: "Hide Touch Type Trainer", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        app.addItem(withTitle: "Quit Touch Type Trainer", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = app

        let editItem = NSMenuItem(); main.addItem(editItem)
        let edit = NSMenu(title: "Edit")
        edit.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        edit.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        edit.addItem(.separator())
        edit.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        edit.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = edit

        let viewItem = NSMenuItem(); main.addItem(viewItem)
        let view = NSMenu(title: "View")
        let zi = view.addItem(withTitle: "Zoom In", action: #selector(zoomIn(_:)), keyEquivalent: "+"); zi.target = self
        let zi2 = view.addItem(withTitle: "Zoom In", action: #selector(zoomIn(_:)), keyEquivalent: "="); zi2.target = self
        zi2.isHidden = true; zi2.allowsKeyEquivalentWhenHidden = true
        let zo = view.addItem(withTitle: "Zoom Out", action: #selector(zoomOut(_:)), keyEquivalent: "-"); zo.target = self
        let zr = view.addItem(withTitle: "Actual Size", action: #selector(zoomReset(_:)), keyEquivalent: "0"); zr.target = self
        viewItem.submenu = view

        let winItem = NSMenuItem(); main.addItem(winItem)
        let win = NSMenu(title: "Window")
        win.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        win.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        let fs = win.addItem(withTitle: "Enter Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        fs.keyEquivalentModifierMask = [.command, .control]
        winItem.submenu = win
        NSApp.mainMenu = main
        NSApp.windowsMenu = win
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
