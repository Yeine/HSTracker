//
//  ShortcutRecorderView.swift
//  HSTracker
//
//  Created by HSTracker on 17/12/24.
//  Copyright © 2024 Benjamin Michotte. All rights reserved.
//

import Cocoa

class ShortcutRecorderView: NSView {

    private var isRecording = false
    private var localMonitor: Any?

    var keyCode: Int = 98 {
        didSet {
            updateDisplay()
        }
    }

    var modifierFlags: Int = 0 {
        didSet {
            updateDisplay()
        }
    }

    var onShortcutChanged: ((Int, Int) -> Void)?

    private lazy var backgroundBox: NSBox = {
        let box = NSBox()
        box.boxType = .custom
        box.borderType = .lineBorder
        box.borderWidth = 1
        box.borderColor = NSColor.separatorColor
        box.fillColor = NSColor.controlBackgroundColor
        box.cornerRadius = 4
        box.translatesAutoresizingMaskIntoConstraints = false
        return box
    }()

    private lazy var shortcutLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = NSFont.systemFont(ofSize: 12)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var clearButton: NSButton = {
        let button = NSButton()
        button.bezelStyle = .inline
        button.isBordered = false
        button.image = NSImage(named: NSImage.stopProgressFreestandingTemplateName)
        button.imageScaling = .scaleProportionallyDown
        button.target = self
        button.action = #selector(clearShortcut)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.toolTip = "Clear shortcut"
        return button
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(backgroundBox)
        backgroundBox.addSubview(shortcutLabel)
        addSubview(clearButton)

        NSLayoutConstraint.activate([
            backgroundBox.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundBox.topAnchor.constraint(equalTo: topAnchor),
            backgroundBox.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundBox.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -4),

            shortcutLabel.centerXAnchor.constraint(equalTo: backgroundBox.centerXAnchor),
            shortcutLabel.centerYAnchor.constraint(equalTo: backgroundBox.centerYAnchor),
            shortcutLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundBox.leadingAnchor, constant: 8),
            shortcutLabel.trailingAnchor.constraint(lessThanOrEqualTo: backgroundBox.trailingAnchor, constant: -8),

            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 16),
            clearButton.heightAnchor.constraint(equalToConstant: 16)
        ])

        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(startRecording))
        backgroundBox.addGestureRecognizer(clickGesture)

        updateDisplay()
    }

    private func updateDisplay() {
        if isRecording {
            shortcutLabel.stringValue = "Press a key..."
            backgroundBox.borderColor = NSColor.controlAccentColor
        } else {
            shortcutLabel.stringValue = shortcutString(keyCode: keyCode, modifiers: modifierFlags)
            backgroundBox.borderColor = NSColor.separatorColor
        }
    }

    @objc private func startRecording() {
        guard !isRecording else { return }

        isRecording = true
        updateDisplay()

        window?.makeFirstResponder(self)

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self = self else { return event }

            if event.type == .keyDown {
                if event.keyCode == 53 {
                    self.stopRecording()
                    return nil
                }

                self.keyCode = Int(event.keyCode)
                self.modifierFlags = Int(event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue)
                self.onShortcutChanged?(self.keyCode, self.modifierFlags)
                self.stopRecording()
                return nil
            }

            return event
        }
    }

    private func stopRecording() {
        isRecording = false

        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }

        updateDisplay()
    }

    @objc private func clearShortcut() {
        keyCode = 98
        modifierFlags = 0
        onShortcutChanged?(keyCode, modifierFlags)
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func resignFirstResponder() -> Bool {
        if isRecording {
            stopRecording()
        }
        return super.resignFirstResponder()
    }

    private func shortcutString(keyCode: Int, modifiers: Int) -> String {
        var result = ""

        let flags = NSEvent.ModifierFlags(rawValue: UInt(modifiers))

        if flags.contains(.control) {
            result += "⌃"
        }
        if flags.contains(.option) {
            result += "⌥"
        }
        if flags.contains(.shift) {
            result += "⇧"
        }
        if flags.contains(.command) {
            result += "⌘"
        }

        result += keyCodeToString(keyCode)

        return result
    }

    private func keyCodeToString(_ keyCode: Int) -> String {
        let keyCodeMap: [Int: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
            38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
            45: "N", 46: "M", 47: ".",

            36: "↩", 48: "⇥", 49: "Space", 51: "⌫", 53: "⎋",

            96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8",
            101: "F9", 103: "F11", 105: "F13", 107: "F14",
            109: "F10", 111: "F12", 113: "F15", 118: "F4",
            120: "F2", 122: "F1",

            123: "←", 124: "→", 125: "↓", 126: "↑"
        ]

        return keyCodeMap[keyCode] ?? "Key\(keyCode)"
    }
}
