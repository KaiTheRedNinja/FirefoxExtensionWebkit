//
//  WindowController+Navigation.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

extension WindowController {
    @objc func goBack() {
        pageViewController?.goBack()
    }

    @objc func goForward() {
        pageViewController?.goForward()
    }

    func changePageURL(to newValue: String) {
        pageViewController?.loadPage(string: newValue)
    }

    func updateAddressBar(to newValue: String) {
        addressBar?.textField.stringValue = newValue
    }
}
