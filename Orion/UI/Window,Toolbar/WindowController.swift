//
//  WindowController.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa
import Combine
import ExtensionsModel
import ExtensionsUI

class WindowController: NSWindowController {
    var pageViewController: PageViewController? {
        self.contentViewController as? PageViewController
    }

    var addressBar: AddressBarView?

    var extensionCancelalble: AnyCancellable?

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

        // watch the extension manager for new extensions
        extensionCancelalble = ExtensionManager.shared.$extensions.sink { [weak self] newValue in
            guard let toolbar = self?.window?.toolbar else {
                print("Toolbar does not exist")
                return
            }

            // get the toolbar's current extensions
            let currentItems = toolbar.items
            let extensions = currentItems.compactMap {
                $0.view as? ExtensionToolbarButton
            }

            // add new extensions if they were added
            let toAdd = newValue.filter { ext in
                !extensions.contains(where: { $0.correspondingExtension?.identifier == ext.identifier })
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for extToAdd in toAdd {
                    toolbar.insertItem(withItemIdentifier: .init(extToAdd.identifier), at: toolbar.items.count)
                }
            }
        }
    }
}
