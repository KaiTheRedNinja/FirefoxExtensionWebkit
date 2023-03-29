//
//  WindowController+NSToolbarDelegate.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa
import ExtensionsModel
import ExtensionsUI

/// The basic items that make up a browser
let baseItems: [NSToolbarItem.Identifier] = [
    .backForward,
    .addressBar,
    .plusButton,
    .flexibleSpace
]

extension WindowController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return baseItems + ExtensionManager.shared.getToolbarIdentifiers()
    }
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return baseItems + ExtensionManager.shared.getToolbarIdentifiers()
    }

    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .addressBar: return addressBar(itemIdentifier: itemIdentifier)
        case .plusButton: return plusButton(itemIdentifier: itemIdentifier)
        case .backForward: return backForward(itemIdentifier: itemIdentifier)
        default:
            if itemIdentifier.rawValue.hasPrefix("extension_") {
                return extensionItem(identifier: itemIdentifier)
            }
        }
        return .init(itemIdentifier: itemIdentifier)
    }

    private func addressBar(itemIdentifier: NSToolbarItem.Identifier) -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .addressBar)
        let addressBar = AddressBarView(frame: .init(x: 0,
                                                     y: -2,
                                                     width: (window?.frame.width ?? 800) - 100,
                                                     height: 25))
        addressBar.mainWindow = self
        self.addressBar = addressBar
        item.view = addressBar
        return item
    }

    private func plusButton(itemIdentifier: NSToolbarItem.Identifier) -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .plusButton)
        let button = NSButton(image: .init(systemSymbolName: "plus",
                                           accessibilityDescription: nil)!,
                              target: nil,
                              action: #selector(newTab))
        button.isBordered = false
        button.bezelStyle = .regularSquare
        item.view = button
        return item
    }

    private func backForward(itemIdentifier: NSToolbarItem.Identifier) -> NSToolbarItem {
        let toolbarItem = NSToolbarItem(itemIdentifier: .backForward)
        let view = NSView()
        toolbarItem.label = "Back/Forward"
        view.frame = CGRect(x: 0, y: 0, width: 50, height: 12)

        // init the go back button
        let leftButton = NSButton(image: NSImage(systemSymbolName: "chevron.left",
                                                 accessibilityDescription: nil)!,
                                  target: nil,
                                  action: #selector(goBack))
        leftButton.isBordered = false
        leftButton.frame = CGRect(x: 0, y: 0, width: view.frame.width/2, height: view.frame.height)
        leftButton.bezelStyle = .regularSquare
        view.addSubview(leftButton)

        // init the go forward button
        let rightButton = NSButton(image: NSImage(systemSymbolName: "chevron.right",
                                                  accessibilityDescription: nil)!,
                                   target: nil,
                                   action: #selector(goForward))
        rightButton.isBordered = false
        rightButton.frame = CGRect(x: view.frame.width/2, y: 0,
                                   width: view.frame.width/2,
                                   height: view.frame.height)
        rightButton.bezelStyle = .regularSquare
        view.addSubview(rightButton)

        toolbarItem.view = view
        return toolbarItem
    }

    private func extensionItem(identifier itemIdentifier: NSToolbarItem.Identifier) -> NSToolbarItem? {
        let idString = itemIdentifier.rawValue
        let manager = ExtensionManager.shared
        // init the toolbar item
        guard let ffExtension = manager.extensions.first(where: { $0.identifier == idString }) else {
            print("Failed to find toolbar: \(idString)")
            return nil
        }

        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        let button = ExtensionToolbarButton(image: ffExtension.iconImage,
                                            target: nil,
                                            action: #selector(showExtensionMenu))
        button.correspondingExtension = ffExtension
        button.isBordered = false
        button.bezelStyle = .circular
        item.view = button
        return item
    }
}

extension NSToolbarItem.Identifier {
    static let addressBar: NSToolbarItem.Identifier = .init(rawValue: "addressBar")
    static let plusButton: NSToolbarItem.Identifier = .init(rawValue: "plusButton")
    static let backForward: NSToolbarItem.Identifier = .init(rawValue: "backForward")
}
