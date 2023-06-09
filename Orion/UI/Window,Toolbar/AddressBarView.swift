//
//  AddressBarView.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

class AddressBarView: NSView {

    var textField: NSTextField

    var mainWindow: WindowController?

    override init(frame frameRect: NSRect) {
        let textField = NSTextField(frame: frameRect)
        self.textField = textField
        super.init(frame: frameRect)

        textField.stringValue = ""
        textField.placeholderString = "Web Address"
        textField.target = self
        textField.action = #selector(updateURL)
        addSubview(textField)
    }

    /// Change the URL of the page to whatever the address bar is
    @objc func updateURL() {
        mainWindow?.changePageURL(to: textField.stringValue)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
