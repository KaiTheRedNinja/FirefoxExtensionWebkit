//
//  ExtensionPopoverViewController.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Cocoa
import WebKit

class ExtensionPopoverViewController: NSViewController {
    private var wkView: WKWebView?

    var correspondengExtension: FirefoxExtension?

    override func viewDidLoad() {
        super.viewDidLoad()

        // load the wkView
        let wkView = WKWebView(frame: self.view.frame)
        wkView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13.2; rv:111.0) Gecko/20100101 Firefox/111.0"
        wkView.autoresizingMask = [.height, .width]
        wkView.navigationDelegate = self
        self.view = wkView
        self.wkView = wkView
    }

    func linkToExtension(ffExtension: FirefoxExtension) {
        self.correspondengExtension = ffExtension
        let pageURL = ffExtension.path.appending(component: ffExtension.popupPage)

        // TODO: Find a more elegant way to load the page other than a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.wkView?.loadFileURL(pageURL, allowingReadAccessTo: pageURL.deletingLastPathComponent())
        }
    }
}

extension ExtensionPopoverViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        print("Web requested to \(navigationAction.request.description)")
        guard let correspondengExtension else { return .cancel }
        print("extension \(correspondengExtension.path.description)")
        if navigationAction.request.description.hasPrefix(correspondengExtension.path.description) {
            print("Allowing")
            return .allow
        } else {
            print("Denying")
            return .cancel
        }
    }
}
