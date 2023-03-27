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

    weak var mainWindow: WindowController?

    private var wkView: NavigatorWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // load the wkView
        let wkView = NavigatorWebView(frame: self.view.frame)
        wkView.navigationDelegate = self
        self.view = wkView
        self.wkView = wkView

        // load contents
        wkView.loadPage(string: "https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")
    }

    /// A dictionary mapping source URLs to destination URLs
    var downloadURLs: [URL: URL] = [:]

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

extension PageViewController: WKNavigationDelegatePlus, WKDownloadDelegate {
    // MARK: Navigation
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        mainWindow?.updateAddressBar(to: url, title: wkView?.title ?? "")
    }

    func webView(_ webView: WKWebView, urlChange: NSKeyValueObservedChange<URL?>) {
        if let wkURL = webView.url {
            mainWindow?.updateAddressBar(to: wkURL, title: wkView?.title ?? "")
        } else {
            print("Could not get URL for page")
        }
    }

    // MARK: Downloads
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 preferences: WKWebpagePreferences,
                 decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if navigationAction.shouldPerformDownload {
            decisionHandler(.download, preferences)
        } else {
            decisionHandler(.allow, preferences)
        }
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.canShowMIMEType {
            decisionHandler(.allow)
        } else {
            decisionHandler(.download)
        }
    }

    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        // TODO: Manage if the download is already downloaded
        download.delegate = self
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }

    func download(_ download: WKDownload,
                  decideDestinationUsing response: URLResponse,
                  suggestedFilename: String,
                  completionHandler: @escaping (URL?) -> Void) {
        let fileManager = FileManager.default
        var url = fileManager.getDocumentsDirectory().appendingPathComponent(suggestedFilename)
        if suggestedFilename.hasSuffix(".xpi") {
            url.deleteLastPathComponent()
            url.append(component: "extensions/\(suggestedFilename)")
        }
        guard let sourceURL = download.originalRequest?.url else { return }
        downloadURLs[sourceURL] = url
        completionHandler(url)
    }

    func downloadDidFinish(_ download: WKDownload) {
        guard let sourceURL = download.originalRequest?.url,
              let destinationURL = downloadURLs[sourceURL] else {
            return
        }
        downloadURLs.removeValue(forKey: sourceURL)
        ExtensionManager.shared.loadXPI(url: destinationURL)
    }
}
