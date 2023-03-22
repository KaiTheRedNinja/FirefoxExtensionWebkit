//
//  WindowController.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

class WindowController: NSWindowController {
    var pageViewController: PageViewController? {
        self.contentViewController as? PageViewController
    }

    var addressBar: AddressBarView?

    override func windowDidLoad() {
        super.windowDidLoad()

        // add the toolbar
        let toolbar = NSToolbar()
        toolbar.delegate = self
        toolbar.centeredItemIdentifiers = [.addressBar]
        window?.toolbar = toolbar
        window?.titleVisibility = .hidden

        // configure the VC
        self.pageViewController?.mainWindow = self
    }
}
