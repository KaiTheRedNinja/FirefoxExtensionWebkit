//
//  ExtensionWebViewController.swift
//  
//
//  Created by Kai Quan Tay on 27/3/23.
//

import Cocoa
import WebKit
import ExtensionsModel
import UniformTypeIdentifiers

open class ExtensionWebViewController: NSViewController {
    private var wkView: WKWebView?

    public var correspondingExtension: FirefoxExtension?
    public var dataSource: ExtensionWebViewDataSource!

    override public func viewDidLoad() {
        guard let correspondingExtension else {
            fatalError("corresponding extension was not found!")
        }

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

        let id = correspondingExtension.identifier
        let pagePath = correspondingExtension.popupPage
        let pageURLString = "firefox-extension://\(id)/\(pagePath)"
        let pageURL = URL(string: pageURLString)!

        let request = URLRequest(url: pageURL)
        self.wkView?.load(request)
    }
}

extension ExtensionWebViewController: WKURLSchemeHandler {
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
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

        let otherComponents = components.dropFirst(1)
        guard let correspondingExtension else {
            print("Corresponding extension does not exist")
            return nil
        }

        // ensure that the accessed URL is within the extension
        let fileURL = correspondingExtension.path.appendingPathComponent(otherComponents.joined(separator: "/"))
        guard fileURL.isContained(in: correspondingExtension.path) else {
            print("Invalid URL")
            return nil
        }

        return fileURL
    }

    private func mimeType(ofFileAtUrl url: URL) -> String? {
        guard let type = UTType(filenameExtension: url.pathExtension) else {
            return nil
        }
        return type.preferredMIMEType
    }

    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}

extension ExtensionWebViewController: WKUIDelegate, WKScriptMessageHandler {
    public func webView(_ webView: WKWebView,
                        runJavaScriptTextInputPanelWithPrompt prompt: String,
                        defaultText: String?,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (String?) -> Void) {

        guard let (funcName, paramData) = JSAPIFunctions.serializeAPIRequest(prompt: prompt) else {
            completionHandler("could not serialize data")
            return
        }

        switch funcName {
        case "getTopSites":
            let topSites = dataSource.getTopSites(number: 10)
            guard let topSitesData = try? JSONEncoder().encode(topSites),
                  let stringValue = String(data: topSitesData, encoding: .utf8)
            else { break }
            completionHandler(stringValue)
            return
        case "createTab", "updateCurrentTab":
            guard let params = paramData as? [String: String],
                  let urlString = params["url"],
                  let url = URL(string: urlString)
            else { break }
            if funcName == "createTab" {
                dataSource.createTab(url: url)
            } else if funcName == "updateCurrentTab" {
                dataSource.updateTab(url: url)
            }
        case "isNewTab":
            // new_tab is the opposite of isNewTab
            completionHandler(String(!dataSource.isNewTab()))
            return
        default: break
        }

        completionHandler(nil)
    }

    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        print("[JAVASCRIPT] \(message.name): \(message.body)")
    }
}
