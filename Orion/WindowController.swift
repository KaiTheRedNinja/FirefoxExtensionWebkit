//
//  WindowController.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()

        // add the toolbar
        let toolbar = NSToolbar()
        toolbar.delegate = self
        window?.toolbar = toolbar
        window?.titleVisibility = .hidden
    }
}
