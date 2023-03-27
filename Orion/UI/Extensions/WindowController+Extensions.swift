//
//  WindowController+Extensions.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Cocoa
import Extensions

extension WindowController {
    @objc func showExtensionMenu(sender: Any?) {
        guard let sender = sender as? ExtensionToolbarButton,
              let ffExtensionID = sender.correspondingExtension?.identifier
        else { return }

        // create the popover
        let popover = NSPopover()
        popover.contentSize = .init(width: 300, height: 400)
        popover.behavior = .transient

        // manage its contents
        let content = ExtensionPopoverViewController()
        guard let ffExtension = ExtensionManager.shared.extensions.first(where: {
            $0.identifier == ffExtensionID
        }) else { return }

        content.correspondengExtension = ffExtension

        // show it
        popover.contentViewController = content
        popover.show(relativeTo: .zero, of: sender, preferredEdge: .maxY)
    }
}
