//
//  NavWebView+NavigationDelegate.swift
//  Orion
//
//  Created by Kai Quan Tay on 28/3/23.
//

import Cocoa
import WebKit

protocol WKNavigationDelegatePlus: WKNavigationDelegate {
    func webView(_ webView: WKWebView, urlChange: NSKeyValueObservedChange<URL?>)
    func webView(_ webView: WKWebView, titleChange: NSKeyValueObservedChange<String?>)
}
