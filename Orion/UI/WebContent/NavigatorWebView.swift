//
//  NavigatorWebView.swift
//  Orion
//
//  Created by Kai Quan Tay on 25/3/23.
//

import Cocoa
import WebKit

class NavigatorWebView: WKWebView {
    var webViewURLObserver: NSKeyValueObservation?

    override init(frame frameRect: CGRect, configuration: WKWebViewConfiguration = .init()) {
        print("Creating web view with frame \(frameRect)")
        super.init(frame: frameRect, configuration: configuration)

        /*
         For reference: Default user agent is
         Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)
         AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15
         */
        // use the firefox UA to get the firefox addon page to work
        customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13.2; rv:111.0) Gecko/20100101 Firefox/111.0"
        autoresizingMask = [.height, .width]

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

protocol WKNavigationDelegatePlus: WKNavigationDelegate {
    func webView(_ webView: WKWebView, urlChange: NSKeyValueObservedChange<URL?>)
}