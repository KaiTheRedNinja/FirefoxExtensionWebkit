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
    weak var mainWindow: WindowController?

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
}

extension ViewController: WKNavigationDelegate {
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
}
