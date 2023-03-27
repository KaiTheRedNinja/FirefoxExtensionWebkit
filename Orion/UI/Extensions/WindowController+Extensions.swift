//
//  WindowController+Extensions.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Cocoa
import ExtensionsModel
import ExtensionsUI

extension WindowController: ExtensionWebViewDataSource {
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
        content.dataSource = self
        guard let ffExtension = ExtensionManager.shared.extensions.first(where: {
            $0.identifier == ffExtensionID
        }) else { return }

        content.correspondingExtension = ffExtension

        // show it
        popover.contentViewController = content
        popover.show(relativeTo: .zero, of: sender, preferredEdge: .maxY)
    }

    func getTopSites(number: Int) -> [(URL, ExtensionsUI.SiteData)] {
        TopSitesAPI.getTopSites(number: number)
    }
}
