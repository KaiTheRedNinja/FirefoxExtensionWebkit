//
//  PageViewController.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa
import WebKit

class PageViewController: NSViewController {

    weak var mainWindow: WindowController?

    private var wkView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // load the wkView
        let wkView = WKWebView(frame: self.view.frame)
        /*
         For reference: Default user agent is
         Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)
         AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15
        */
        // use the firefox UA to get the firefox addon page to work
        wkView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13.2; rv:111.0) Gecko/20100101 Firefox/111.0"
        wkView.autoresizingMask = [.height, .width]
        wkView.navigationDelegate = self
        self.view = wkView
        self.wkView = wkView

        // load contents
        loadPage(string: "https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")
    }

    func loadPage(string: String) {
        guard let url = URL(string: string) else { return }
        let request = URLRequest(url: url)
        wkView?.load(request)
    }

    func goBack() {
        wkView?.goBack()
    }

    func goForward() {
        wkView?.goForward()
    }

    /// A dictionary mapping source URLs to destination URLs
    var downloadURLs: [URL: URL] = [:]
}

extension PageViewController: WKNavigationDelegate, WKDownloadDelegate {
    // MARK: Navigation
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Web view started navigation!")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Finished!")
        mainWindow?.updateAddressBar(to: webView.url?.description ?? "")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Failed :(")
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
        let response = navigationResponse.response
        print("Deciding policy for \(response.url?.description ?? "no url")")
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
        let url = getDocumentsDirectory().appendingPathComponent(suggestedFilename)
        guard let sourceURL = download.originalRequest?.url else {
            print("Original request does not exist")
            return
        }
        downloadURLs[sourceURL] = url
        completionHandler(url)
    }

    func downloadDidFinish(_ download: WKDownload) {
        guard let sourceURL = download.originalRequest?.url,
              let destinationURL = downloadURLs[sourceURL] else {
            print("Original request or destination URL does not exist")
            return
        }
        downloadURLs.removeValue(forKey: sourceURL)
        FirefoxExtension.decodeFromXPI(url: destinationURL)
    }

    // TODO: Download finished
}
