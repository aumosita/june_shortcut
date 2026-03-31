import SwiftUI
import AppKit

struct KeyRecorderView: NSViewRepresentable {
    @ObservedObject var viewModel: KeyRecorderViewModel

    func makeNSView(context: Context) -> KeyRecorderNSView {
        let view = KeyRecorderNSView()
        view.onKeyCombo = { combo in
            viewModel.recordKeyCombo(combo)
        }
        view.onStartRecording = {
            viewModel.startRecording()
        }
        view.onStopRecording = {
            viewModel.stopRecording()
        }
        return view
    }

    func updateNSView(_ nsView: KeyRecorderNSView, context: Context) {
        nsView.displayText = viewModel.displayText
        nsView.isRecording = viewModel.state == .recording
        nsView.needsDisplay = true
    }
}

final class KeyRecorderNSView: NSView {
    var onKeyCombo: ((KeyCombo) -> Void)?
    var onStartRecording: (() -> Void)?
    var onStopRecording: (() -> Void)?
    var displayText: String = "단축키를 설정하세요"
    var isRecording: Bool = false

    private var trackingArea: NSTrackingArea?

    override var acceptsFirstResponder: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.borderWidth = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: 200, height: 28)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        layer?.backgroundColor = isRecording
            ? NSColor.controlAccentColor.withAlphaComponent(0.1).cgColor
            : NSColor.controlBackgroundColor.cgColor
        layer?.borderColor = isRecording
            ? NSColor.controlAccentColor.cgColor
            : NSColor.separatorColor.cgColor

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: isRecording ? NSColor.controlAccentColor : NSColor.labelColor,
            .paragraphStyle: paragraphStyle,
        ]

        let textRect = bounds.insetBy(dx: 8, dy: 4)
        (displayText as NSString).draw(in: textRect, withAttributes: attrs)
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        if !isRecording {
            onStartRecording?()
        }
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        if event.keyCode == 53 { // Escape
            onStopRecording?()
            return
        }

        let combo = KeyCombo.fromNSEvent(keyCode: UInt16(event.keyCode), modifierFlags: event.modifierFlags)
        if combo.hasModifiers {
            onKeyCombo?(combo)
        }
    }

    override func resignFirstResponder() -> Bool {
        if isRecording {
            onStopRecording?()
        }
        return super.resignFirstResponder()
    }
}
