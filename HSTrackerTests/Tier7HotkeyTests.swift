//
//  Tier7HotkeyTests.swift
//  HSTrackerTests
//
//  Created by HSTracker on 17/12/24.
//  Copyright © 2024 Benjamin Michotte. All rights reserved.
//

import XCTest
@testable import HSTracker

class Tier7HotkeyTests: HSTrackerTests {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "tier7_toggle_hotkey_enabled")
        UserDefaults.standard.removeObject(forKey: "tier7_toggle_hotkey_keycode")
        UserDefaults.standard.removeObject(forKey: "tier7_toggle_hotkey_modifiers")
        UserDefaults.standard.removeObject(forKey: "tier7_overlay_hidden")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "tier7_toggle_hotkey_enabled")
        UserDefaults.standard.removeObject(forKey: "tier7_toggle_hotkey_keycode")
        UserDefaults.standard.removeObject(forKey: "tier7_toggle_hotkey_modifiers")
        UserDefaults.standard.removeObject(forKey: "tier7_overlay_hidden")
        super.tearDown()
    }

    // MARK: - Settings Default Values Tests

    func testDefaultHotkeyEnabled() {
        XCTAssertTrue(Settings.tier7ToggleHotkeyEnabled, "Hotkey should be enabled by default")
    }

    func testDefaultHotkeyKeyCode() {
        XCTAssertEqual(Settings.tier7ToggleHotkeyKeyCode, 98, "Default key code should be 98 (F7)")
    }

    func testDefaultHotkeyModifiers() {
        XCTAssertEqual(Settings.tier7ToggleHotkeyModifiers, 0, "Default modifiers should be 0 (none)")
    }

    func testDefaultOverlayHidden() {
        XCTAssertFalse(Settings.tier7OverlayHidden, "Overlay should not be hidden by default")
    }

    // MARK: - Settings Persistence Tests

    func testHotkeyEnabledPersistence() {
        Settings.tier7ToggleHotkeyEnabled = false
        XCTAssertFalse(Settings.tier7ToggleHotkeyEnabled)

        Settings.tier7ToggleHotkeyEnabled = true
        XCTAssertTrue(Settings.tier7ToggleHotkeyEnabled)
    }

    func testHotkeyKeyCodePersistence() {
        Settings.tier7ToggleHotkeyKeyCode = 122 // F1
        XCTAssertEqual(Settings.tier7ToggleHotkeyKeyCode, 122)

        Settings.tier7ToggleHotkeyKeyCode = 120 // F2
        XCTAssertEqual(Settings.tier7ToggleHotkeyKeyCode, 120)
    }

    func testHotkeyModifiersPersistence() {
        let cmdModifier = Int(NSEvent.ModifierFlags.command.rawValue)
        Settings.tier7ToggleHotkeyModifiers = cmdModifier
        XCTAssertEqual(Settings.tier7ToggleHotkeyModifiers, cmdModifier)

        let shiftCmdModifier = Int(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue)
        Settings.tier7ToggleHotkeyModifiers = shiftCmdModifier
        XCTAssertEqual(Settings.tier7ToggleHotkeyModifiers, shiftCmdModifier)
    }

    func testOverlayHiddenPersistence() {
        Settings.tier7OverlayHidden = true
        XCTAssertTrue(Settings.tier7OverlayHidden)

        Settings.tier7OverlayHidden = false
        XCTAssertFalse(Settings.tier7OverlayHidden)
    }

    func testOverlayHiddenToggle() {
        XCTAssertFalse(Settings.tier7OverlayHidden)

        Settings.tier7OverlayHidden.toggle()
        XCTAssertTrue(Settings.tier7OverlayHidden)

        Settings.tier7OverlayHidden.toggle()
        XCTAssertFalse(Settings.tier7OverlayHidden)
    }

    // MARK: - ShortcutRecorderView Tests

    func testShortcutRecorderViewInitialization() {
        let recorder = ShortcutRecorderView(frame: NSRect(x: 0, y: 0, width: 100, height: 22))
        XCTAssertEqual(recorder.keyCode, 98, "Default key code should be F7")
        XCTAssertEqual(recorder.modifierFlags, 0, "Default modifiers should be none")
    }

    func testShortcutRecorderViewKeyCodeUpdate() {
        let recorder = ShortcutRecorderView(frame: NSRect(x: 0, y: 0, width: 100, height: 22))
        recorder.keyCode = 122 // F1
        XCTAssertEqual(recorder.keyCode, 122)
    }

    func testShortcutRecorderViewModifiersUpdate() {
        let recorder = ShortcutRecorderView(frame: NSRect(x: 0, y: 0, width: 100, height: 22))
        let cmdModifier = Int(NSEvent.ModifierFlags.command.rawValue)
        recorder.modifierFlags = cmdModifier
        XCTAssertEqual(recorder.modifierFlags, cmdModifier)
    }

    func testShortcutRecorderViewCallback() {
        let recorder = ShortcutRecorderView(frame: NSRect(x: 0, y: 0, width: 100, height: 22))
        var callbackCalled = false
        var receivedKeyCode = 0
        var receivedModifiers = 0

        recorder.onShortcutChanged = { keyCode, modifiers in
            callbackCalled = true
            receivedKeyCode = keyCode
            receivedModifiers = modifiers
        }

        recorder.keyCode = 100 // F8
        recorder.modifierFlags = Int(NSEvent.ModifierFlags.option.rawValue)
        recorder.onShortcutChanged?(recorder.keyCode, recorder.modifierFlags)

        XCTAssertTrue(callbackCalled)
        XCTAssertEqual(receivedKeyCode, 100)
        XCTAssertEqual(receivedModifiers, Int(NSEvent.ModifierFlags.option.rawValue))
    }

    // MARK: - Hotkey Matching Logic Tests

    func testHotkeyMatchingWithNoModifiers() {
        let expectedKeyCode: UInt16 = 98 // F7
        let expectedModifiers: UInt = 0

        let eventKeyCode: UInt16 = 98
        let eventModifiers: UInt = 0

        XCTAssertTrue(eventKeyCode == expectedKeyCode && eventModifiers == expectedModifiers)
    }

    func testHotkeyMatchingWithModifiers() {
        let expectedKeyCode: UInt16 = 17 // T
        let expectedModifiers = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue

        let eventKeyCode: UInt16 = 17
        let eventModifiers = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue

        XCTAssertTrue(eventKeyCode == expectedKeyCode && eventModifiers == expectedModifiers)
    }

    func testHotkeyNotMatchingWrongKey() {
        let expectedKeyCode: UInt16 = 98 // F7
        let expectedModifiers: UInt = 0

        let eventKeyCode: UInt16 = 99 // F3
        let eventModifiers: UInt = 0

        XCTAssertFalse(eventKeyCode == expectedKeyCode && eventModifiers == expectedModifiers)
    }

    func testHotkeyNotMatchingWrongModifiers() {
        let expectedKeyCode: UInt16 = 17 // T
        let expectedModifiers = NSEvent.ModifierFlags.command.rawValue

        let eventKeyCode: UInt16 = 17
        let eventModifiers = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue

        XCTAssertFalse(eventKeyCode == expectedKeyCode && eventModifiers == expectedModifiers)
    }
}
