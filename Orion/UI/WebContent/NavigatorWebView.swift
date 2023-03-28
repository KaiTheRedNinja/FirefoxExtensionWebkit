//
//  NavigatorWebView.swift
//  Orion
//
//  Created by Kai Quan Tay on 25/3/23.
//

import Cocoa
import WebKit
import ExtensionsModel

class NavigatorWebView: WKWebView {
    var mainWindow: WindowController?

    var webViewURLObserver: NSKeyValueObservation?

    /// A dictionary mapping source URLs to destination URLs
    var downloadURLs: [URL: URL] = [:]

    override init(frame frameRect: CGRect, configuration: WKWebViewConfiguration = .init()) {
        super.init(frame: frameRect, configuration: configuration)

        // use the firefox UA to get the firefox addon page to work
        customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13.2; rv:111.0) Gecko/20100101 Firefox/111.0"
        autoresizingMask = [.height, .width]
        navigationDelegate = self

        // watch the address
        self.webViewURLObserver = observe(\.url) { [weak self] webView, change in
            guard let navDelegate = self?.navigationDelegate as? WKNavigationDelegatePlus else { return }
            navDelegate.webView(webView, urlChange: change)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadPage(string: String) {
        guard let url = URL(string: string) else { return }
        let request = URLRequest(url: url)
        /*
         NOTE: triggers error:
         This method should not be called on the main thread as it may lead to UI unresponsiveness.
         */
        load(request)
    }
}

// MARK: Navigation
extension NavigatorWebView: WKNavigationDelegatePlus {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        mainWindow?.updateAddressBar(to: url, title: self.title ?? "")
    }

    func webView(_ webView: WKWebView, urlChange: NSKeyValueObservedChange<URL?>) {
        if let wkURL = webView.url {
            mainWindow?.updateAddressBar(to: wkURL, title: self.title ?? "")
        } else {
            print("Could not get URL for page")
        }
    }
}

// MARK: Downloads
extension NavigatorWebView: WKDownloadDelegate {
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

protocol WKNavigationDelegatePlus: WKNavigationDelegate {
    func webView(_ webView: WKWebView, urlChange: NSKeyValueObservedChange<URL?>)
}
