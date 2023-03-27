//
//  FirefoxExtension.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

/// A structure containing information about a firefox extension
public struct FirefoxExtension {
    /// The author of the extension
    public let author: String
    /// A dictionary mapping icon sizes to their paths relative to ``path``
    public let icons: [Int: String]

    /// The name of the extension
    public let name: String
    /// The path of the extension's root directory. All other paths are relative to this.
    public let path: URL
    /// The description of the extension
    public let description: String
    /// The path to the pop-up page displayed when the toolbar icon is clicked, relative to ``path``
    public let popupPage: String
    /// The path to a configuration page, relative to ``path``
    public let optionsPage: String
    /// The permissions that this extension requires
    public let permissions: [String]

    init(author: String,
         icons: [Int: String],
         name: String,
         path: URL,
         description: String,
         popupPage: String,
         optionsPage: String,
         permissions: [String]) {
        self.author = author
        self.icons = icons
        self.name = name
        self.path = path
        self.description = description
        self.popupPage = popupPage
        self.optionsPage = optionsPage
        self.permissions = permissions

        let size = 24
        if let imageName = icons[size],
           let image = NSImage(contentsOf: path.appendingPathComponent(imageName)) {
            self.iconImage = image
        } else {
            self.iconImage = .init(systemSymbolName: "questionmark.circle", accessibilityDescription: nil)!
        }

        let nameComponent = name.replacingOccurrences(of: " ", with: "-")
        let authorComponent = author.replacingOccurrences(of: " ", with: "-")

        self.toolbarItem = .init("extension_\(nameComponent)_\(authorComponent)")
    }

    /// The toolbar item identifier for this extension
    public let toolbarItem: NSToolbarItem.Identifier
    /// The icon image for this extension. Defaults to size 24.
    public let iconImage: NSImage

    // TODO: Use a UUID or smth instead
    /// An identifier for this extension. Based on the extension's name and author.
    public var identifier: String {
        let nameComponent = name.replacingOccurrences(of: " ", with: "-")
        let authorComponent = author.replacingOccurrences(of: " ", with: "-")

        return "extension_\(nameComponent)_\(authorComponent)"
    }
}
