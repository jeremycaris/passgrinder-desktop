import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Prevent macOS from restoring previous window state
    self.isRestorable = false

    // Set window size: macOS uses points (not pixels); on Retina, 1 point = 2 pixels
    let desiredContentSize = NSSize(width: 500, height: 450)
    self.setContentSize(desiredContentSize)
    self.minSize = desiredContentSize
    self.maxSize = desiredContentSize
    
    // Center window on screen
    self.center()
    
    // Log actual window frame after setting
    print("🔍 MainFlutterWindow after awakeFromNib:")
    print("   contentSize: \(self.contentView?.frame.size ?? .zero)")
    print("   frame: \(self.frame)")
    print("   minSize: \(self.minSize)")
    print("   maxSize: \(self.maxSize)")

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
