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

        JSAPIFunctions.setUp(webView: wkView,
                             uiDelegate: self,
                             messageHandler: self)

        self.view = wkView
        self.wkView = wkView
    }

    func linkToExtension(ffExtension: FirefoxExtension) {
        self.correspondengExtension = ffExtension
        let pageURL = ffExtension.path.appending(component: ffExtension.popupPage)

        // TODO: Find a more elegant way to load the page other than a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.wkView?.loadFileURL(pageURL, allowingReadAccessTo: ffExtension.path)
            let request = URLRequest(url: pageURL)
            self.wkView?.load(request)
        }
    }
}

extension ExtensionPopoverViewController: WKUIDelegate, WKScriptMessageHandler {
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {

        guard let (funcName, _) = JSAPIFunctions.serializeAPIRequest(prompt: prompt) else {
            completionHandler("could not serialize data")
            return
        }
        print("Function name reeeeee")

        switch funcName {
        case "getTopSites":
            print("Getting top sites")
            let topSites = TopSitesAPI.getTopSites(number: 10)
            let topSitesDict: [[String: String]] = topSites.map { url, data in
                ["url": url.description, "title": data.title]
            }
            guard let topSitesData = try? JSONEncoder().encode(topSitesDict),
                  let stringValue = String(data: topSitesData, encoding: .utf8)
            else { break }
            completionHandler(stringValue)
            return
        default: break
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Got message \(message.name): \(message.body)")
    }
}
