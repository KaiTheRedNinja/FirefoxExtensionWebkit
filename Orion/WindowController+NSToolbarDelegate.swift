//
//  WindowController+NSToolbarDelegate.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

extension WindowController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .addressBar,
            .plusButton
        ]
    }
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .addressBar,
            .plusButton
        ]
    }
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .addressBar:
            // create the address bar
            let item = NSToolbarItem(itemIdentifier: .addressBar)
            item.view = NSImageView(image: .init(systemSymbolName: "circle", accessibilityDescription: nil)!)
            return item
        case .plusButton:
            // create the plus button
            let item = NSToolbarItem(itemIdentifier: .plusButton)
            item.view = NSImageView(image: .init(systemSymbolName: "plus", accessibilityDescription: nil)!)
            return item
        default:
            return .init(itemIdentifier: itemIdentifier)
        }
    }
}

extension NSToolbarItem.Identifier {
    static let addressBar: NSToolbarItem.Identifier = .init(rawValue: "addressBar")
    static let plusButton: NSToolbarItem.Identifier = .init(rawValue: "plusButton")
}
