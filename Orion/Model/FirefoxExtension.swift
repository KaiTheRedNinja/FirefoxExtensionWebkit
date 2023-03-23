//
//  FirefoxExtension.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

struct FirefoxExtension {
    let author: String
    let icons: [Int: String]

    let name: String
    let path: URL
    let description: String
    let optionsUIPage: String
    let permissions: [String]

    init(author: String,
         icons: [Int: String],
         name: String,
         path: URL,
         description: String,
         optionsUIPage: String,
         permissions: [String]) {
        self.author = author
        self.icons = icons
        self.name = name
        self.path = path
        self.description = description
        self.optionsUIPage = optionsUIPage
        self.permissions = permissions

        let size = 24
        if let imageName = icons[size],
           let image = NSImage(contentsOf: path.appending(component: imageName)) {
            self.iconImage = image
        } else {
            self.iconImage = .init(systemSymbolName: "questionmark.circle", accessibilityDescription: nil)!
        }

        self.toolbarItem = .init("extension_\(name.replacing(" ", with: "-"))_\(author.replacing(" ", with: "-"))")
    }

    let toolbarItem: NSToolbarItem.Identifier
    let iconImage: NSImage

    var identifier: String {
        "extension_\(name.replacing(" ", with: "-"))_\(author.replacing(" ", with: "-"))"
    }
}
