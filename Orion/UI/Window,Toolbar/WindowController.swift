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
    /// `contentViewController` as a ``PageViewController``
    var pageViewController: PageViewController? {
        self.contentViewController as? PageViewController
    }

    /// A reference to the address bar, for updating its contents whenever needed
    var addressBar: AddressBarView?

    /// A cancellable that contains a sink watching the list of extensions
    ///
    /// Whenever this sink is triggered, it runs the ``extensionsUpdated(newValue:)`` function
    var extensionCancelalble: AnyCancellable?

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.minSize = .init(width: 630, height: 400)

        // add the toolbar
        let toolbar = NSToolbar()
        toolbar.delegate = self
        toolbar.centeredItemIdentifier = .addressBar
        window?.toolbar = toolbar
        window?.titleVisibility = .hidden

        // configure the VC
        self.pageViewController?.mainWindow = self

        // watch the extension manager for new extensions
        extensionCancelalble = ExtensionManager.shared.$extensions.sink(receiveValue: extensionsUpdated)
    }

    /// Updates the toolbar whenever an extension is downloaded
    func extensionsUpdated(newValue: [FirefoxExtension]) {
        guard let toolbar = self.window?.toolbar else {
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

        // in this implementation, you cannot delete extensions
        // if you could, you would remove old extensions if they were deleted here

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for extToAdd in toAdd {
                toolbar.insertItem(withItemIdentifier: .init(extToAdd.identifier), at: toolbar.items.count)
            }
        }
    }
}
