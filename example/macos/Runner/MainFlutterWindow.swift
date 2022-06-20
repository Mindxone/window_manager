import Cocoa
import FlutterMacOS

class BlurryContainerViewController: NSViewController {
  let flutterViewController = FlutterViewController()

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  override func loadView() {
    let blurView = NSVisualEffectView()
    blurView.autoresizingMask = [.width, .height]
    blurView.blendingMode = .behindWindow
    blurView.state = .active
    if #available(macOS 10.14, *) {
        blurView.material = .sidebar
    }
    self.view = blurView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.addChild(flutterViewController)

    flutterViewController.view.frame = self.view.bounds
    flutterViewController.view.autoresizingMask = [.width, .height]
    self.view.addSubview(flutterViewController.view)
  }
}

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  override func awakeFromNib() {
    delegate = self

    let blurryContainerViewController = BlurryContainerViewController()
    let windowFrame = self.frame
    self.contentViewController = blurryContainerViewController
    self.setFrame(windowFrame, display: true)

    // Doing this gives us a toolbar (that we're going to make transparent) but it gives
    // a bit more real estate to grab and drag with.
    if #available(macOS 10.13, *) {
      let customToolbar = NSToolbar()
      customToolbar.showsBaselineSeparator = false
      self.toolbar = customToolbar
    }

    // Don't show the title bar
    self.titleVisibility = .hidden

    // Weirdly, you'd think we wouldn't need this because we're hiding the titlebar
    // on the previous line, but if we don't, then the toolbar is shown opaquely.
    self.titlebarAppearsTransparent = true

    // Allows the user to grab by the title/tool bar and move around
    self.isMovableByWindowBackground = true

    // Combines both titlebar and toolbar
    if #available(macOS 11.0, *) {
        self.toolbarStyle = .unified
    }

    // Without this, the content view on the right sits underneath the toolbar
    self.styleMask.insert(.fullSizeContentView)

    // Making the window itself transparent
    self.isOpaque = false
    self.backgroundColor = .clear

    RegisterGeneratedPlugins(registry: blurryContainerViewController.flutterViewController)

    super.awakeFromNib()
  }

  func window(_ window: NSWindow, willUseFullScreenPresentationOptions proposedOptions: NSApplication.PresentationOptions = []) -> NSApplication.PresentationOptions {
    // Hides the toolbar when in fullscreen mode
    return [.autoHideToolbar, .autoHideMenuBar, .fullScreen]
  }
}