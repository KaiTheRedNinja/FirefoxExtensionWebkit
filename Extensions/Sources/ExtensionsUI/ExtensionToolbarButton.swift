//
//  ExtensionToolbarButton.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Cocoa
import ExtensionsModel

/// An NSButton for an extension in the toolbar, containing additional information about the extension it represents
public class ExtensionToolbarButton: NSButton {
    /// The extension that this extension toolbar button corresponds with
    public var correspondingExtension: FirefoxExtension?
}
