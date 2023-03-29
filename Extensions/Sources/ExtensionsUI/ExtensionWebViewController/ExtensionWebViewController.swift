//
//  ExtensionWebViewController.swift
//  
//
//  Created by Kai Quan Tay on 27/3/23.
//

import Cocoa
import WebKit
import ExtensionsModel

open class ExtensionWebViewController: NSViewController {
    private var wkView: WKWebView?

    /// The extension that this web view controller corresponds with
    public var correspondingExtension: FirefoxExtension?
    /// The data source for the WebAPIs
    public var dataSource: ExtensionWebViewDataSource!

    override public func viewDidLoad() {
        // The corresponding extension should have been assigned when this view was initialised
        // so we need to make sure it exists
        guard let correspondingExtension else {
            fatalError("corresponding extension was not found!")
        }
        super.viewDidLoad()

        // register the firefox-extension custom URL scheme
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(self, forURLScheme: "firefox-extension")

        // load the wkView
        let wkView = WKWebView(frame: self.view.frame, configuration: configuration)

        // use the firefox UA
        wkView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13.2; rv:111.0) Gecko/20100101 Firefox/111.0"
        wkView.autoresizingMask = [.height, .width]

        self.view = wkView
        self.wkView = wkView

        JSAPIFunctions.setUp(webView: wkView,
                             for: correspondingExtension,
                             uiDelegate: self,
                             messageHandler: self)

        // Use the custom URL scheme to load the page
        let id = correspondingExtension.identifier
        let pagePath = correspondingExtension.popupPage
        let pageURLString = "firefox-extension://\(id)/\(pagePath)"
        let pageURL = URL(string: pageURLString)!

        let request = URLRequest(url: pageURL)
        self.wkView?.load(request)
    }
}
