//
//  PageViewController.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa
import WebKit
import ExtensionsModel

class PageViewController: NSViewController {

    weak var mainWindow: WindowController? {
        didSet { wkView?.mainWindow = mainWindow }
    }

    private var wkView: NavigatorWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // load the wkView
        let wkView = NavigatorWebView(frame: self.view.frame)
        self.view = wkView
        self.wkView = wkView

        // load contents
        wkView.loadPage(string: "https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")
    }

    // MARK: Public-facing functions

    func goBack() {
        wkView?.goBack()
    }

    func goForward() {
        wkView?.goForward()
    }

    func loadPage(string: String) {
        wkView?.loadPage(string: string)
    }
}
