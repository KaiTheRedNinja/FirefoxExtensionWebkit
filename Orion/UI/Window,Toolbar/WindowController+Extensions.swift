//
//  WindowController+Extensions.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Cocoa

extension WindowController {
    @objc func showExtensionMenu(sender: Any?) {
        guard let sender = sender as? ExtensionToolbarButton,
              let ffExtension = sender.correspondingExtension?.identifier
        else { return }
        print("Sender: \(sender)")
        print("Target: \(ffExtension)")
    }
}
