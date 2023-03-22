//
//  WindowController+Navigation.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

extension WindowController {
    @objc func goBack() {
        viewController?.goBack()
    }

    @objc func goForward() {
        viewController?.goForward()
    }

    func changePageURL(to newValue: String) {
        viewController?.loadPage(string: newValue)
    }

    func updateAddressBar(to newValue: String) {
        addressBar?.textField.stringValue = newValue
    }
}
