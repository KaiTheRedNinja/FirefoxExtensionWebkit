//
//  ExtensionWebViewController+WKURLShemeHandler.swift
//  
//
//  Created by Kai Quan Tay on 29/3/23.
//

import Cocoa
import WebKit
import UniformTypeIdentifiers

/**
 When the raw file:// url is used, there are issues.

 # Problem:
 For example, take the following file structure
 ```
 /path/to/extension/
 ├─ popup/
 ├─ panel.html
 ├─ panel.js
 ```
 In this example, to load panel.html, the URL would be `file:///path/to/extension/popup/panel.html`

 Within panel.html, it has the following html element: `<script src="/popup/panel.js"></script>`.
 The expected file to load is `file:///path/to/extension/popup/panel.js`. However, since the "root" in this
 system is not `/path/to/extension` but rather the root of the computer (`/`), the URL that WebKit attempts to load is
 `file:///popup/panel.js`, which will not exist.

 # Solution:
 WebKit has a  `loadFileURL` function that takes an optional `allowingReadAccessTo` URL. However, this approach
 did not work.

 My solution uses a custom URL scheme, namely `firefox-extension`. The file url above would translate to
 `firefox-extension://[extension id]/popup/panel.html`. The ``ExtensionWebViewController``
 intercepts this request via `WKURLSchemeHandler`, and supplies webkit with the contents of the correct file.

 In this new system, `<script src="/popup/panel.js"></script>` would be correctly loaded as
 `firefox-extension://[extension id]/popup/panel.js`.
 */
extension ExtensionWebViewController: WKURLSchemeHandler {
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url,
              let fileUrl = fileUrlFromUrl(url),
              let mimeType = mimeType(ofFileAtUrl: fileUrl),
              let data = try? Data(contentsOf: fileUrl) else { return }

        let response = HTTPURLResponse(url: url,
                                       mimeType: mimeType,
                                       expectedContentLength: data.count, textEncodingName: nil)

        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    /// Translates a `firefox-extension://` url representing a page in
    /// the extension to its corresponding `file://` URL
    /// - Parameter baseURL: The `firefox-extension` URL
    /// - Returns: The corresponding `file://` URL, if it exists.
    private func fileUrlFromUrl(_ baseURL: URL) -> URL? {
        let components = baseURL.pathComponents
        // the 1st item should be nil
        // the 2nd item onwards should be the path of the file

        let otherComponents = components.dropFirst(1)
        guard let correspondingExtension else {
            print("Corresponding extension does not exist")
            return nil
        }

        // ensure that the accessed URL is within the extension
        let fileURL = correspondingExtension.path.appendingPathComponent(otherComponents.joined(separator: "/"))
        guard fileURL.isContained(in: correspondingExtension.path) else {
            print("Invalid URL")
            return nil
        }

        return fileURL
    }

    private func mimeType(ofFileAtUrl url: URL) -> String? {
        guard let type = UTType(filenameExtension: url.pathExtension) else {
            return nil
        }
        return type.preferredMIMEType
    }

    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}
