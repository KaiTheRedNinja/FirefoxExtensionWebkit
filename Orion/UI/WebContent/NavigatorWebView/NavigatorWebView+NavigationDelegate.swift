//
//  NavigatorWebView+NavigationDelegate.swift
//  Orion
//
//  Created by Kai Quan Tay on 28/3/23.
//

import Cocoa
import WebKit

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

    func webView(_ webView: WKWebView, titleChange: NSKeyValueObservedChange<String?>) {
        if let wkTitle = webView.title, let wkURL = webView.url {
            mainWindow?.updateTabTitle(of: wkURL, to: wkTitle)
        } else {
            print("Could not get title or URL")
        }
    }
}

public protocol WKNavigationDelegatePlus: WKNavigationDelegate {
    /// Tells the delegate that the URL of the web view has changed
    func webView(_ webView: WKWebView, urlChange: NSKeyValueObservedChange<URL?>)
    /// Tells the delegate that the title of the web view has changed
    func webView(_ webView: WKWebView, titleChange: NSKeyValueObservedChange<String?>)
}
