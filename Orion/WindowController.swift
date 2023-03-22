//
//  WindowController.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

class WindowController: NSWindowController {
    var viewController: ViewController? {
        self.contentViewController as? ViewController
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
        self.viewController?.mainWindow = self
    }

    func changePageURL(to newValue: String) {
        viewController?.loadPage(string: newValue)
    }

    func updateAddressBar(to newValue: String) {
        print("Address bar: \(addressBar?.description)")
        addressBar?.textField.stringValue = newValue
    }
}
