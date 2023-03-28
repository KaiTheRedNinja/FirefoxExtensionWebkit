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

    func getTopSites(number: Int) -> [[String: String]] {
        let topSites = TopSitesAPI.getTopSites(number: number)
        return topSites.map { item in
            [
                "url": item.0.description,
                "title": item.1.title
            ]
        }
    }

    func isNewTab() -> Bool {
        // if the current tab's URL is "about:blank" or nil, it is a newtab.
        let currentURL = pageViewController?.currentURL()?.description
        return currentURL == nil || currentURL == "about:blank"
    }

    func createTab(url: URL) {
        print("Creating tab with url: \(url)")
        changePageURL(to: url.description)
    }

    func updateTab(url: URL) {
        print("Updating tab to url: \(url)")
        changePageURL(to: url.description)
    }
}
