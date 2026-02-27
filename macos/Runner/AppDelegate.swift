import Cocoa
import FlutterMacOS
import ServiceManagement

@main
class AppDelegate: FlutterAppDelegate, NSMenuDelegate {
  var statusItem: NSStatusItem?
  var mainWindow: MainFlutterWindow?
  var statusMenu: NSMenu?
  var customStatusButton: NSStatusBarButton?
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    if let button = statusItem?.button {
      if let icon = loadAppIcon() {
        button.image = icon
      } else {
        button.title = "🔐"
      }
      
      // Send action on both left and right mouse up (not down)
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
      button.action = #selector(statusItemClicked(_:))
      button.target = self
      customStatusButton = button
    }
    
    setupStatusMenu()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      for window in NSApplication.shared.windows {
        if window.isKind(of: MainFlutterWindow.self) {
          self.mainWindow = (window as! MainFlutterWindow)
          self.mainWindow?.orderOut(nil)
          break
        }
      }
    }
    
    // Setup MethodChannel for settings (launch at login)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
      if let flutterVC = self.mainWindow?.contentViewController as? FlutterViewController {
        let settingsChannel = FlutterMethodChannel(name: "settings", binaryMessenger: flutterVC.engine.binaryMessenger)
        settingsChannel.setMethodCallHandler { [weak self] call, result in
          switch call.method {
          case "setLaunchAtLogin":
            if let enabled = call.arguments as? Bool {
              self?.setLaunchAtLogin(enabled)
              result(nil)
            } else {
              result(FlutterError(code: "INVALID_ARGUMENT", message: nil, details: nil))
            }
          case "getLaunchAtLogin":
            result(self?.isLaunchAtLoginEnabled() ?? false)
          default:
            result(FlutterMethodNotImplemented)
          }
        }
      }
    }
    
    super.applicationDidFinishLaunching(notification)
  }
  
  func loadAppIcon() -> NSImage? {
    let bundlePath = Bundle.main.bundlePath
    let possiblePaths = [
      "\(bundlePath)/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/icon/app_icon.png",
      "\(bundlePath)/Contents/Resources/flutter_assets/assets/icon/app_icon.png",
      "\(bundlePath)/Contents/Resources/app_icon.png",
      "\(bundlePath)/app_icon.png",
    ]
    
    for path in possiblePaths {
      if FileManager.default.fileExists(atPath: path) {
        if let image = NSImage(contentsOfFile: path) {
          // Create a properly sized version for menu bar
          let resized = NSImage(size: NSSize(width: 16, height: 16))
          resized.lockFocus()
          image.draw(in: NSRect(x: 0, y: 0, width: 16, height: 16), from: .zero, operation: .sourceOver, fraction: 1.0)
          resized.unlockFocus()
          return resized
        }
      }
    }
    
    if let image = NSImage(named: "app_icon") {
      let resized = NSImage(size: NSSize(width: 16, height: 16))
      resized.lockFocus()
      image.draw(in: NSRect(x: 0, y: 0, width: 16, height: 16), from: .zero, operation: .sourceOver, fraction: 1.0)
      resized.unlockFocus()
      return resized
    }
    
    return nil
  }
  
  func setupStatusMenu() {
    statusMenu = NSMenu()
    statusMenu?.delegate = self
    
    // Add Quit option
    let quitItem = NSMenuItem(
      title: "Quit PassGrinder",
      action: #selector(quitApp(_:)),
      keyEquivalent: "q"
    )
    quitItem.target = self
    statusMenu?.addItem(quitItem)
  }
  
  @objc func statusItemClicked(_ sender: NSStatusBarButton) {
    guard let event = NSApplication.shared.currentEvent else { return }
    
    // Check button number: 0 = left, 1 = right
    if event.buttonNumber == 1 {
      // Right-click
      showContextMenu()
    } else {
      // Left-click (default action)
      toggleWindow(sender)
    }
  }
  
  @objc func showContextMenu() {
    if let statusItem = statusItem, let menu = statusMenu {
      statusItem.menu = menu
      statusItem.button?.performClick(nil)
    }
  }
  
  // MARK: - NSMenuDelegate
  
  func menuDidClose(_ menu: NSMenu) {
    // Clear the menu after it closes to restore normal left-click behavior
    DispatchQueue.main.async {
      self.statusItem?.menu = nil
    }
  }
  
  @objc func toggleWindow(_ sender: AnyObject?) {
    guard let window = mainWindow else { return }
    
    if window.isVisible {
      window.sendAppEvent("appHidden")
      window.orderOut(nil)
    } else {
      NSApp.activate(ignoringOtherApps: true)
      window.makeKeyAndOrderFront(nil)
      positionWindowNearStatusBar()
    }
  }
  
  func positionWindowNearStatusBar() {
    guard let window = mainWindow,
          let statusButton = statusItem?.button,
          let screen = NSScreen.main else { return }
    
    let screenFrame = screen.frame
    let menuBarHeight: CGFloat = 26
    let padding: CGFloat = 10
    
    // Get the status item button's frame in screen coordinates
    let buttonFrame = statusButton.window?.convertToScreen(statusButton.bounds) ?? .zero
    
    // Position window below menu bar, aligned with or near the status icon
    let windowSize = window.frame.size
    
    // Calculate x position: center below status icon if possible, otherwise keep right edge close to screen edge
    var x = buttonFrame.midX - (windowSize.width / 2)
    
    // Ensure window doesn't go off screen on either side
    let minX = padding
    let maxX = screenFrame.maxX - windowSize.width - padding
    
    if x < minX {
      x = minX
    } else if x > maxX {
      x = maxX
    }
    
    // Position below menu bar
    let y = screenFrame.maxY - menuBarHeight - windowSize.height - padding
    
    window.setFrameOrigin(NSPoint(x: x, y: y))
  }
  
  @objc func quitApp(_ sender: AnyObject?) {
    mainWindow?.sendAppEvent("appWillTerminate")
    NSApplication.shared.terminate(self)
  }

  override func applicationDidBecomeActive(_ notification: Notification) {
    super.applicationDidBecomeActive(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

// MARK: - Launch at Login
extension AppDelegate {
  func setLaunchAtLogin(_ enabled: Bool) {
    if #available(macOS 13.0, *) {
      // Modern API (macOS 13+)
      if enabled {
        try? SMAppService.mainApp.register()
      } else {
        try? SMAppService.mainApp.unregister()
      }
    }
    // Legacy API (macOS 10.15–12) no longer supported
  }
  
  func isLaunchAtLoginEnabled() -> Bool {
    if #available(macOS 13.0, *) {
      return SMAppService.mainApp.status == .enabled
    }
    return false
  }
}

