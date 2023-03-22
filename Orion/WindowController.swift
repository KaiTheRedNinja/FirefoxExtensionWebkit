//
//  WindowController.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // add the toolbar
        let toolbar = NSToolbar()
        toolbar.delegate = self
        window?.toolbar = toolbar
        window?.titleVisibility = .hidden
    }
}

extension WindowController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .cloudSharing,
            .showColors,
            .showFonts
        ]
    }
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .cloudSharing,
            .showColors,
            .showFonts
        ]
    }
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        return .init(itemIdentifier: itemIdentifier)
    }
}
