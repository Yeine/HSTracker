//
//  InteractionTests.swift
//  HSTrackerTests
//
//  Created on 18/12/24.
//  Copyright © 2024 Benjamin Michotte. All rights reserved.
//

import XCTest
@testable import HSTracker

class InteractionTests: HSTrackerTests {

    private var game: Game!

    override func setUp() {
        super.setUp()
        game = Game(hearthstoneRunState: HearthstoneRunState(isRunning: false, isActive: false))
    }

    override func tearDown() {
        game = nil
        super.tearDown()
    }

    // MARK: - isInteractionAllowed Tests

    func testIsInteractionAllowed_WhenHearthstoneActive_ReturnsTrue() {
        game.setHearthstoneActived(flag: true)
        game.setSelfActivated(flag: false)

        XCTAssertTrue(game.isInteractionAllowed, "Interaction should be allowed when Hearthstone is active")
    }

    func testIsInteractionAllowed_WhenSelfActive_ReturnsTrue() {
        game.setHearthstoneActived(flag: false)
        game.setSelfActivated(flag: true)

        XCTAssertTrue(game.isInteractionAllowed, "Interaction should be allowed when HSTracker is active")
    }

    func testIsInteractionAllowed_WhenBothActive_ReturnsTrue() {
        game.setHearthstoneActived(flag: true)
        game.setSelfActivated(flag: true)

        XCTAssertTrue(game.isInteractionAllowed, "Interaction should be allowed when both apps are active")
    }

    func testIsInteractionAllowed_WhenNeitherActive_ReturnsFalse() {
        game.setHearthstoneActived(flag: false)
        game.setSelfActivated(flag: false)

        XCTAssertFalse(game.isInteractionAllowed, "Interaction should NOT be allowed when neither app is active")
    }
}
