//
//  BattlegroundsTierDetailsViewTests.swift
//  HSTrackerTests
//

import XCTest
@testable import HSTracker

class BattlegroundsTierDetailsViewTests: HSTrackerTests {

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	// MARK: - Constants Tests

	func testMinCardHeightConstant() {
		XCTAssertEqual(BattlegroundsTierDetailsView.minCardHeight, CGFloat(kTinyRowHeight), "Min card height should equal tiny row height")
		XCTAssertEqual(BattlegroundsTierDetailsView.minCardHeight, 17.0, "Min card height should be 17.0")
	}

	func testGroupHeaderHeightConstant() {
		XCTAssertEqual(BattlegroundsTierDetailsView.groupHeaderHeight, 30.0, "Group header height should be 30.0")
	}

	func testMinCardHeightIsSmallestSize() {
		XCTAssertLessThanOrEqual(BattlegroundsTierDetailsView.minCardHeight, CGFloat(kTinyRowHeight), "Min height should be <= tiny")
		XCTAssertLessThanOrEqual(BattlegroundsTierDetailsView.minCardHeight, CGFloat(kSmallRowHeight), "Min height should be <= small")
		XCTAssertLessThanOrEqual(BattlegroundsTierDetailsView.minCardHeight, CGFloat(kMediumRowHeight), "Min height should be <= medium")
		XCTAssertLessThanOrEqual(BattlegroundsTierDetailsView.minCardHeight, CGFloat(kRowHeight), "Min height should be <= big")
	}

	// MARK: - Layout Calculation Tests

	func testCardHeightCalculationNoCompression() {
		// When total height fits within available space, no compression needed
		let cardHeight = CGFloat(kRowHeight) // 34.0
		let totalCards = 10
		let groupCount = 2
		let availableHeight: CGFloat = 500.0

		let headerHeight = BattlegroundsTierDetailsView.groupHeaderHeight * CGFloat(groupCount)
		let totalHeight = headerHeight + CGFloat(totalCards) * cardHeight

		// 60 + 340 = 400, which is less than 500
		XCTAssertLessThan(totalHeight, availableHeight, "Content should fit without compression")
	}

	func testCardHeightCalculationWithCompression() {
		// When total height exceeds available space, compression is needed
		let cardHeight = CGFloat(kRowHeight) // 34.0
		let totalCards = 30
		let groupCount = 5
		let availableHeight: CGFloat = 400.0

		let headerHeight = BattlegroundsTierDetailsView.groupHeaderHeight * CGFloat(groupCount)
		let totalHeightUncompressed = headerHeight + CGFloat(totalCards) * cardHeight

		// 150 + 1020 = 1170, which exceeds 400
		XCTAssertGreaterThan(totalHeightUncompressed, availableHeight, "Content should need compression")

		// Calculate compressed height
		let availableForCards = availableHeight - headerHeight
		let compressedHeight = availableForCards / CGFloat(totalCards)

		// (400 - 150) / 30 = 8.33, which is less than min height (17)
		XCTAssertLessThan(compressedHeight, BattlegroundsTierDetailsView.minCardHeight, "Compressed height would be below minimum")
	}

	func testMinCardHeightEnforcement() {
		// Verify that card height never goes below minimum
		let totalCards = 50
		let groupCount = 8
		let availableHeight: CGFloat = 300.0

		let headerHeight = BattlegroundsTierDetailsView.groupHeaderHeight * CGFloat(groupCount)
		let availableForCards = availableHeight - headerHeight
		let compressedHeight = availableForCards / CGFloat(totalCards)

		// Apply minimum enforcement (same logic as in layout())
		let enforcedHeight = max(compressedHeight, BattlegroundsTierDetailsView.minCardHeight)

		XCTAssertGreaterThanOrEqual(enforcedHeight, BattlegroundsTierDetailsView.minCardHeight, "Card height should never be below minimum")
		XCTAssertEqual(enforcedHeight, BattlegroundsTierDetailsView.minCardHeight, "Card height should be clamped to minimum")
	}

	func testTotalHeightWithMinCardHeight() {
		// When using minimum card height, total height may exceed available space (enabling scroll)
		let totalCards = 40
		let groupCount = 6
		let availableHeight: CGFloat = 350.0

		let headerHeight = BattlegroundsTierDetailsView.groupHeaderHeight * CGFloat(groupCount)
		let totalHeightWithMin = headerHeight + CGFloat(totalCards) * BattlegroundsTierDetailsView.minCardHeight

		// 180 + 680 = 860, which exceeds 350
		XCTAssertGreaterThan(totalHeightWithMin, availableHeight, "Content with min height should exceed available space, enabling scroll")
	}

	// MARK: - View Initialization Tests

	func testViewInitialization() {
		let view = BattlegroundsTierDetailsView()
		XCTAssertTrue(view.isFlipped, "View should be flipped for natural scroll behavior")
		XCTAssertEqual(view.contentFrame, NSRect.zero, "Initial content frame should be zero")
		XCTAssertNil(view.onContentChanged, "Initial callback should be nil")
	}

	func testViewFrameInitialization() {
		let frame = NSRect(x: 0, y: 0, width: 300, height: 400)
		let view = BattlegroundsTierDetailsView(frame: frame)
		XCTAssertTrue(view.isFlipped, "View should be flipped")
		XCTAssertEqual(view.frame, frame, "Frame should match initialization")
	}

	// MARK: - Callback Tests

	func testOnContentChangedCallback() {
		let view = BattlegroundsTierDetailsView()
		var callbackInvoked = false

		view.onContentChanged = {
			callbackInvoked = true
		}

		// Manually invoke to test callback is properly set
		view.onContentChanged?()

		XCTAssertTrue(callbackInvoked, "Callback should be invoked when called")
	}
}
