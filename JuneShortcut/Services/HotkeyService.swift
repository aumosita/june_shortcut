import Cocoa

private func hotkeyCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else { return Unmanaged.passRetained(event) }

    let service = Unmanaged<HotkeyService>.fromOpaque(userInfo).takeUnretainedValue()

    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = service.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passRetained(event)
    }

    guard type == .keyDown else { return Unmanaged.passRetained(event) }

    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    let flags = event.flags.intersection(.maskNonCoalesced.union(.maskCommand).union(.maskShift).union(.maskAlternate).union(.maskControl))
    let deviceIndependentFlags = flags.intersection(
        CGEventFlags([.maskCommand, .maskShift, .maskAlternate, .maskControl])
    )
    let combo = KeyCombo(keyCode: keyCode, modifiers: deviceIndependentFlags.rawValue)

    if let action = service.registeredCombos[combo] {
        DispatchQueue.main.async { action() }
        return nil
    }

    return Unmanaged.passRetained(event)
}

final class HotkeyService: ObservableObject {
    static let shared = HotkeyService()

    fileprivate var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    fileprivate var registeredCombos: [KeyCombo: () -> Void] = [:]

    @Published var isRunning = false

    private init() {}

    func start() {
        guard eventTap == nil else { return }

        let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: hotkeyCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            isRunning = false
            return
        }

        eventTap = tap

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        isRunning = true
    }

    func stop() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            runLoopSource = nil
        }
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            eventTap = nil
        }
        isRunning = false
    }

    func register(combo: KeyCombo, action: @escaping () -> Void) {
        registeredCombos[combo] = action
    }

    func unregister(combo: KeyCombo) {
        registeredCombos.removeValue(forKey: combo)
    }

    func unregisterAll() {
        registeredCombos.removeAll()
    }

    func rebindAll(entries: [ShortcutEntry], launchService: AppLaunchService = .shared) {
        unregisterAll()
        for entry in entries where entry.isEnabled {
            register(combo: entry.keyCombo) {
                launchService.launch(targets: entry.targets)
            }
        }
    }
}
