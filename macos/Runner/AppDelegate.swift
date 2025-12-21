import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  var statusItem: NSStatusItem?
  var mainWindow: MainFlutterWindow?
  var statusMenu: NSMenu?
  var customStatusButton: NSStatusBarButton?
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    if let button = statusItem?.button {
      if let icon = loadAppIcon() {
        button.image = icon
      } else {
        // No emoji fallback - just show nothing if PNG fails
        button.title = ""
      }
      
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
          let scaledImage = NSImage(size: NSSize(width: 18, height: 18))
          scaledImage.lockFocus()
          image.draw(in: NSRect(x: 0, y: 0, width: 18, height: 18))
          scaledImage.unlockFocus()
          return scaledImage
        }
      }
    }
    
    if let image = NSImage(named: "app_icon") {
      let scaledImage = NSImage(size: NSSize(width: 18, height: 18))
      scaledImage.lockFocus()
      image.draw(in: NSRect(x: 0, y: 0, width: 18, height: 18))
      scaledImage.unlockFocus()
      return scaledImage
    }
    
    return nil
  }
  
  func setupStatusMenu() {
    statusMenu = NSMenu()
    
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
    guard let event = NSApplication.shared.currentEvent else {
      toggleWindow(sender)
      return
    }
    
    // Right click (buttonNumber 1) shows menu
    if event.buttonNumber == 1 {
      if let statusItem = statusItem, let menu = statusMenu {
        statusItem.menu = menu
      }
    } else {
      // Left click (buttonNumber 0) toggles window
      statusItem?.menu = nil
      toggleWindow(sender)
    }
  }
  
  @objc func toggleWindow(_ sender: AnyObject?) {
    guard let window = mainWindow else { return }
    
    if window.isVisible {
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
    NSApplication.shared.terminate(self)
  }

  override func applicationDidBecomeActive(_ notification: Notification) {
    super.applicationDidBecomeActive(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return false
  }
}

