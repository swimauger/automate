import Foundation
import ApplicationServices

@_cdecl("initEventLoop")
public func initEventLoop() {
  RunLoop.current.run()
}

public var keyListener: (@convention(c) (UnsafePointer<CChar>, Int) -> Void)?;

@_cdecl("createKeyListener")
public func createKeyListener(listener: @convention(c) (UnsafePointer<CChar>, Int) -> Void) {
  let keyDownEvent = 1 << CGEventType.keyDown.rawValue
  let keyUpEvent = 1 << CGEventType.keyUp.rawValue
  keyListener = listener

  guard let tap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: CGEventMask(keyDownEvent | keyUpEvent),
    callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
      let eventType = type == .keyDown ? "keydown" : "keyup"
      let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
      if keyCode == 0x08 && event.flags.contains(.maskControl) && eventType == "keydown" {
        print("KeyboardInterrupt: Exiting event loop.")
        exit(0)
      } else {
        keyListener!(eventType.cString(using: .utf8)!, keyCode)
      }
      return Unmanaged.passUnretained(event)
    },
    userInfo: nil
  ) else {
    print("Failed to create key listener")
    abort()
  }

  let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
  CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
  CGEvent.tapEnable(tap: tap, enable: true)
}
