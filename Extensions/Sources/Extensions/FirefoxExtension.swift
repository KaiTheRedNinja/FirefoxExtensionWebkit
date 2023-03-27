//
//  FirefoxExtension.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

public struct FirefoxExtension {
    public let author: String
    public let icons: [Int: String]

    public let name: String
    public let path: URL
    public let description: String
    public let popupPage: String
    public let optionsPage: String
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

    public let toolbarItem: NSToolbarItem.Identifier
    public let iconImage: NSImage

    public var identifier: String {
        let nameComponent = name.replacingOccurrences(of: " ", with: "-")
        let authorComponent = author.replacingOccurrences(of: " ", with: "-")

        return "extension_\(nameComponent)_\(authorComponent)"
    }
}
