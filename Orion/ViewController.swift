//
//  ViewController.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    var wkView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // load the wkView
        let wkView = WKWebView(frame: self.view.frame)
        wkView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
        "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15"
        wkView.autoresizingMask = [.height, .width]
        wkView.navigationDelegate = self
        self.view = wkView
        self.wkView = wkView

        // load contents
        let url = URL(string: "https://www.kagi.com")!
        let request = URLRequest(url: url)
        wkView.load(request)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Web view started navigation!")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Finished!")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Failed :(")
    }
}
