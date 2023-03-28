//
//  NavigatorWebView+WKDownloadDelegate.swift
//  Orion
//
//  Created by Kai Quan Tay on 28/3/23.
//

import Cocoa
import WebKit
import ExtensionsModel

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
            url.appendPathComponent("extensions/\(suggestedFilename)")
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
        if destinationURL.lastPathComponent.hasSuffix(".xpi") {
            ExtensionManager.shared.loadXPI(url: destinationURL)
        }
    }
}
