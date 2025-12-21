import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  func sendAppEvent(_ name: String) {
    if let vc = self.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "appEvents", binaryMessenger: vc.engine.binaryMessenger)
      channel.invokeMethod(name, arguments: nil)
    }
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    self.isRestorable = false
    self.hidesOnDeactivate = false
    
    // Make window chromeless but valid
    self.styleMask = [.borderless]
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    
    // Hide system buttons
    self.standardWindowButton(.closeButton)?.isHidden = true
    self.standardWindowButton(.miniaturizeButton)?.isHidden = true
    self.standardWindowButton(.zoomButton)?.isHidden = true
    
    self.isOpaque = false
    self.backgroundColor = NSColor.clear
    self.level = .floating

    let desiredContentSize = NSSize(width: 460, height: 360)
    self.setContentSize(desiredContentSize)
    self.minSize = desiredContentSize
    self.maxSize = desiredContentSize

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
  
  // Allow the window to properly handle keyboard input
  override var canBecomeKey: Bool {
    return true
  }
  
  override var canBecomeMain: Bool {
    return true
  }
  
  // Hide window when it loses focus, but only if clicking outside
  override func resignKey() {
    // Don't hide immediately - let the user interact with the window
    // Only hide if they click outside the app
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      if !NSApplication.shared.isActive {
        self.sendAppEvent("appHidden")
        self.orderOut(nil)
      }
    }
    super.resignKey()
  }
}


