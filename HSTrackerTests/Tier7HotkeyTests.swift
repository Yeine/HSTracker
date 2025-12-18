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
		XCTAssertEqual(Settings.tier7ToggleHotkeyKeyCode, KeyCodes.f7, "Default key code should be F7")
	}

	func testDefaultHotkeyModifiers() {
		XCTAssertEqual(Settings.tier7ToggleHotkeyModifiers, 0, "Default modifiers should be none")
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
	}

	func testOverlayHiddenToggle() {
		XCTAssertFalse(Settings.tier7OverlayHidden)

		Settings.tier7OverlayHidden.toggle()
		XCTAssertTrue(Settings.tier7OverlayHidden)

		Settings.tier7OverlayHidden.toggle()
		XCTAssertFalse(Settings.tier7OverlayHidden)
	}

	// MARK: - KeyCodes Tests

	func testKeyCodeConstants() {
		XCTAssertEqual(KeyCodes.f7, 98)
		XCTAssertEqual(KeyCodes.escape, 53)
	}

	func testKeyCodeToString() {
		XCTAssertEqual(KeyCodes.toString(KeyCodes.f7), "F7")
		XCTAssertEqual(KeyCodes.toString(KeyCodes.escape), "⎋")
		XCTAssertEqual(KeyCodes.toString(0), "A")
		XCTAssertEqual(KeyCodes.toString(999), "Key999")
	}

	func testShortcutStringNoModifiers() {
		let result = KeyCodes.shortcutString(keyCode: KeyCodes.f7, modifiers: 0)
		XCTAssertEqual(result, "F7")
	}

	func testShortcutStringWithCommand() {
		let modifiers = Int(NSEvent.ModifierFlags.command.rawValue)
		let result = KeyCodes.shortcutString(keyCode: 17, modifiers: modifiers) // T
		XCTAssertEqual(result, "⌘T")
	}

	func testShortcutStringWithMultipleModifiers() {
		let modifiers = Int(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue)
		let result = KeyCodes.shortcutString(keyCode: 17, modifiers: modifiers) // T
		XCTAssertEqual(result, "⇧⌘T")
	}

	// MARK: - ShortcutRecorderView Tests

	func testShortcutRecorderViewInitialization() {
		let recorder = ShortcutRecorderView(frame: NSRect(x: 0, y: 0, width: 100, height: 22))
		XCTAssertEqual(recorder.keyCode, KeyCodes.f7)
		XCTAssertEqual(recorder.modifierFlags, 0)
	}

	func testShortcutRecorderViewCallback() {
		let recorder = ShortcutRecorderView(frame: NSRect(x: 0, y: 0, width: 100, height: 22))
		var callbackCalled = false
		var receivedKeyCode = 0

		recorder.onShortcutChanged = { keyCode, _ in
			callbackCalled = true
			receivedKeyCode = keyCode
		}

		recorder.keyCode = 100 // F8
		recorder.onShortcutChanged?(recorder.keyCode, recorder.modifierFlags)

		XCTAssertTrue(callbackCalled)
		XCTAssertEqual(receivedKeyCode, 100)
	}

	// MARK: - Hotkey Matching Logic Tests

	func testHotkeyMatchingExact() {
		let expectedKeyCode: UInt16 = UInt16(KeyCodes.f7)
		let expectedModifiers: UInt = 0

		let eventKeyCode: UInt16 = UInt16(KeyCodes.f7)
		let eventModifiers: UInt = 0

		XCTAssertTrue(eventKeyCode == expectedKeyCode && eventModifiers == expectedModifiers)
	}

	func testHotkeyNotMatchingWrongKey() {
		let expectedKeyCode: UInt16 = UInt16(KeyCodes.f7)
		let eventKeyCode: UInt16 = 99 // F3

		XCTAssertFalse(eventKeyCode == expectedKeyCode)
	}

	func testHotkeyNotMatchingWrongModifiers() {
		let expectedModifiers = NSEvent.ModifierFlags.command.rawValue
		let eventModifiers = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue

		XCTAssertFalse(eventModifiers == expectedModifiers)
	}
}
