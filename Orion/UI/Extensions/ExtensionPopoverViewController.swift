//
//  ExtensionPopoverViewController.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Cocoa
import WebKit
import UniformTypeIdentifiers

class ExtensionPopoverViewController: NSViewController {
    private var wkView: WKWebView?

    var correspondengExtension: FirefoxExtension?

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(self, forURLScheme: "firefox-extension")

        // load the wkView
        let wkView = WKWebView(frame: self.view.frame, configuration: configuration)
        // use the firefox UA to get the firefox addon page to work
        wkView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13.2; rv:111.0) Gecko/20100101 Firefox/111.0"
        wkView.autoresizingMask = [.height, .width]

        self.view = wkView
        self.wkView = wkView

        JSAPIFunctions.setUp(webView: wkView,
                             uiDelegate: self,
                             messageHandler: self)
    }

    func linkToExtension(ffExtension: FirefoxExtension) {
        self.correspondengExtension = ffExtension
        let pageURLString = "firefox-extension://\(ffExtension.identifier)/\(ffExtension.popupPage)"
        let pageURL = URL(string: pageURLString)!

        // TODO: Find a more elegant way to load the page other than a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let request = URLRequest(url: pageURL)
            print("Loading URL: \(pageURL)")
            self.wkView?.load(request)
        }
    }
}

extension ExtensionPopoverViewController: WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("Starting URL scheme task")
        guard let url = urlSchemeTask.request.url,
              let fileUrl = fileUrlFromUrl(url),
              let mimeType = mimeType(ofFileAtUrl: fileUrl),
              let data = try? Data(contentsOf: fileUrl) else { return }

        let response = HTTPURLResponse(url: url,
                                       mimeType: mimeType,
                                       expectedContentLength: data.count, textEncodingName: nil)

        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func fileUrlFromUrl(_ baseURL: URL) -> URL? {
        let components = baseURL.pathComponents
        // the 1st item should be nil
        // the 2nd item onwards should be the path of the file

        print("Evaluating componetns: \(components)")

        // TODO: Evaluate the URL properly
        let otherComponents = components.dropFirst(1)
        guard let fileURL = correspondengExtension?.path
                    .appending(component: otherComponents.joined(separator: "/")) else {
            print("Could not get file URL")
            return nil
        }
        print("File url returned: \(fileURL)")
        return fileURL
    }

    private func mimeType(ofFileAtUrl url: URL) -> String? {
        guard let type = UTType(filenameExtension: url.pathExtension) else {
            return nil
        }
        return type.preferredMIMEType
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
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

        switch funcName {
        case "getTopSites":
            let topSites = TopSitesAPI.getTopSites(number: 10)
            let data = topSites.map { item in
                [
                    "url": item.0.description,
                    "title": item.1.title
                ]
            }
            guard let topSitesData = try? JSONEncoder().encode(data),
                  let stringValue = String(data: topSitesData, encoding: .utf8)
            else { break }
            completionHandler(stringValue)
            return
        case "createTab":
            print("[SWIFT] Creating tab!")
            // create the tab
            completionHandler(nil)
        case "updateTab":
            print("[SWIFT] Updating tab!")
            // update the tab
            completionHandler(nil)
        default: break
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("[JAVASCRIPT] \(message.name): \(message.body)")
    }
}
