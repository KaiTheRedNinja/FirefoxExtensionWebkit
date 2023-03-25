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

    func updateAddressBar(to url: URL) {
        let description = url.description
        // dont change it to the same thing
        guard description != addressBar?.textField.stringValue else { return }

        // set the string value and top sites api
        addressBar?.textField.stringValue = description
        TopSitesAPI.addSiteVisit(url: url)
    }
}
