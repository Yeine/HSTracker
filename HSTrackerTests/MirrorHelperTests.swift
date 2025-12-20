//
//  MirrorHelperTests.swift
//  HSTrackerTests
//
//  Created for regression testing of ChoicesWatcher crash fix.
//  Tests defensive checks added to prevent crashes when Hearthstone is not running.
//

import XCTest
@testable import HSTracker

class MirrorHelperTests: HSTrackerTests {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - MirrorHelper Tests

    /// Regression test: MirrorHelper should not be initialized when tests run
    /// (Hearthstone is not running during test execution)
    func testMirrorHelperNotInitializedWhenHearthstoneNotRunning() {
        XCTAssertFalse(MirrorHelper.isInitialized(),
                       "MirrorHelper should not be initialized when Hearthstone is not running")
    }

    /// Regression test: getCardChoices should return nil when Hearthstone is not running
    /// This prevents the crash reported in the ChoicesWatcher thread
    func testGetCardChoicesReturnsNilWhenHearthstoneNotRunning() {
        let choices = MirrorHelper.getCardChoices()
        XCTAssertNil(choices,
                     "getCardChoices should return nil when Hearthstone is not running")
    }

    // MARK: - ChoicesWatcherArgs Tests

    /// Test that ChoicesWatcherArgs equality works correctly with nil values
    func testChoicesWatcherArgsEqualityBothNil() {
        let args1 = ChoicesWatcherArgs(choice: nil)
        let args2 = ChoicesWatcherArgs(choice: nil)
        XCTAssertEqual(args1, args2,
                       "Two ChoicesWatcherArgs with nil choices should be equal")
    }

    /// Test that ChoicesWatcherArgs correctly identifies when one is nil
    func testChoicesWatcherArgsEqualityOneNil() {
        let args1 = ChoicesWatcherArgs(choice: nil)
        let mirrorChoice = MirrorCardChoices()
        mirrorChoice.isVisible = true
        mirrorChoice.cards = ["card1", "card2"]
        let args2 = ChoicesWatcherArgs(choice: mirrorChoice)

        XCTAssertNotEqual(args1, args2,
                          "ChoicesWatcherArgs with nil and non-nil choices should not be equal")
    }

    /// Test that ChoicesWatcherArgs equality compares visibility and cards
    func testChoicesWatcherArgsEqualityMatchingValues() {
        let choice1 = MirrorCardChoices()
        choice1.isVisible = true
        choice1.cards = ["card1", "card2"]

        let choice2 = MirrorCardChoices()
        choice2.isVisible = true
        choice2.cards = ["card1", "card2"]

        let args1 = ChoicesWatcherArgs(choice: choice1)
        let args2 = ChoicesWatcherArgs(choice: choice2)

        XCTAssertEqual(args1, args2,
                       "ChoicesWatcherArgs with same visibility and cards should be equal")
    }

    /// Test that ChoicesWatcherArgs detects different visibility
    func testChoicesWatcherArgsEqualityDifferentVisibility() {
        let choice1 = MirrorCardChoices()
        choice1.isVisible = true
        choice1.cards = ["card1"]

        let choice2 = MirrorCardChoices()
        choice2.isVisible = false
        choice2.cards = ["card1"]

        let args1 = ChoicesWatcherArgs(choice: choice1)
        let args2 = ChoicesWatcherArgs(choice: choice2)

        XCTAssertNotEqual(args1, args2,
                          "ChoicesWatcherArgs with different visibility should not be equal")
    }

    /// Test that ChoicesWatcherArgs detects different cards
    func testChoicesWatcherArgsEqualityDifferentCards() {
        let choice1 = MirrorCardChoices()
        choice1.isVisible = true
        choice1.cards = ["card1", "card2"]

        let choice2 = MirrorCardChoices()
        choice2.isVisible = true
        choice2.cards = ["card3", "card4"]

        let args1 = ChoicesWatcherArgs(choice: choice1)
        let args2 = ChoicesWatcherArgs(choice: choice2)

        XCTAssertNotEqual(args1, args2,
                          "ChoicesWatcherArgs with different cards should not be equal")
    }
}
