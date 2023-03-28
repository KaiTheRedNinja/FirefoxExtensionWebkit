//
//  NavigatorWebView.swift
//  Orion
//
//  Created by Kai Quan Tay on 25/3/23.
//

import Cocoa
import WebKit

class NavigatorWebView: WKWebView {
    var mainWindow: WindowController?

    var webViewURLObserver: NSKeyValueObservation?
    var webViewTitleObserver: NSKeyValueObservation?

    /// A dictionary mapping source URLs to destination URLs
    var downloadURLs: [URL: URL] = [:]

    override init(frame frameRect: CGRect, configuration: WKWebViewConfiguration = .init()) {
        super.init(frame: frameRect, configuration: configuration)

        // use the firefox UA to get the firefox addon page to work
        customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13.2; rv:111.0) Gecko/20100101 Firefox/111.0"
        autoresizingMask = [.height, .width]
        navigationDelegate = self

        // watch the address and title
        self.webViewURLObserver = observe(\.url) { [weak self] webView, change in
            guard let navDelegate = self?.navigationDelegate as? WKNavigationDelegatePlus else { return }
            navDelegate.webView(webView, urlChange: change)
        }
        self.webViewTitleObserver = observe(\.title) { [weak self] webView, change in
            guard let navDelegate = self?.navigationDelegate as? WKNavigationDelegatePlus else { return }
            navDelegate.webView(webView, titleChange: change)
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
