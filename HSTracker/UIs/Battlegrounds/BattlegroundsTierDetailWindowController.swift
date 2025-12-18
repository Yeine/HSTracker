//
//  BattlegroundsTierDetailWindowController.swift
//  HSTracker
//
//  Created by Martin BONNIN on 04/01/2020.
//  Copyright © 2020 Benjamin Michotte. All rights reserved.
//

import Foundation

class BattlegroundsTierDetailWindowController: OverWindowController {
    @IBOutlet var detailsView: BattlegroundsTierDetailsView?
    @IBOutlet var scrollView: NSScrollView?

    override var alwaysLocked: Bool {
        return true
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        scrollView?.drawsBackground = false
        scrollView?.backgroundColor = .clear
        scrollView?.contentView.drawsBackground = false
        scrollView?.scrollerStyle = .overlay
        scrollView?.autohidesScrollers = true

        detailsView?.onContentChanged = { [weak self] in
            self?.scrollToTop()
        }
    }

    override func updateFrames() {
    }

    func setTier(tier: Int) {
        detailsView?.setTier(tier: tier)
    }

    func scrollToTop() {
        guard let scrollView = scrollView else { return }
        scrollView.contentView.scroll(to: NSPoint(x: 0, y: 0))
        scrollView.reflectScrolledClipView(scrollView.contentView)
    }
}
