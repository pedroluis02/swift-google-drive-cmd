import Foundation
#if os(OSX)
  import Cocoa
#endif

internal func openURL(_ url: URL) {
  #if os(OSX)
    if !NSWorkspace.shared.open(url) {
      print("default browser could not be opened")
    }
  #else
    print("openURL(\(String(describing:url))) is not implemented on this platform.")
  #endif
}
