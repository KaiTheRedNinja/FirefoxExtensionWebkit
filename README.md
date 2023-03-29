# Orion

My Technical Task for Orion. Supports macOS 11.0 and above, developed on macOS 13.2. 

## Task
Copied from the Orion Engineering Task PDF
1. For this project you will download, compile WebKit and then use the compiled version in your project.
2. Implement topSites web extensions API on top of Webkit.
3. Implement basic parsing of a Firefox extension package so you are able to process it when downloaded.
4. When this browser visits https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/, the user 
should be able to directly install the extension from the site by clicking the “Add to Firefox” button 
(as if the user is visiting it from a Firefox browser).
The browser will then handle downloading and ‘installing’ the extension. The installed extension will 
be visible in the browser as a button on the toolbar and clicking it will render the extension output 
as in Firefox (basically show the list of top sites you visit).
5. Implement a custom WebKit navigation delegate method which will be fired every time when navigation 
changes (including manipulated navigation through History API). For example, addons.mozilla.org uses the 
history API to manipulate the current URL to navigate internal pages, which isn’t supported by the 
existing "decidePolicyFor navigationAction" delegate method. Use that custom navigation delegate method 
to make sure all navigated URLs are served for topSites API.
6. What would you need to change to make this compatible with macOS 10.13?
7. Describe the biggest challenges you faced and how you solved them in the readme.

## Implementation (Tasks 1-5)

Task 1: WebKit is located at WebKit.framework, prebuilt build 262215 from MARCH 28, 2023 AT 09:07 PM GMT+8 from 
https://webkit.org/build-archives/#mac-ventura-x86_64%20arm64

Task 2: The browser detects changes in the URL (see `Task 5` below) and saves them to a json in the application's Documents directory.

<details>
<summary>Web Extension Injection</summary>
The TopSites extension API is implemented in the `/Extensions/Sources/ExtensionsModel/JSAPIFunctions` directory.

To inject the javascript API, the `JSAPIFunctions` object takes in a WebKit view and runs a `WKUserScript`. 
The payload contains a few javascript functions:
- `captureLog`: which redirects `console.log` messages to the Xcode console
- `queryNativeCode`: which provides the application with a function name and its parameters, and returns the application's response
- `getTopSites`: gets a list of the top sites from the application
- `getStorageLocal`: determines if the current tab is a new (empty) tab or not
- `openNewTab` and `updateCurrentTab`: create a new tab or change the current tab's url to a URL

The `queryNativeCode` function works by calling the `prompt` function (usually used for confirmation popups). The
object contains a `payload`, which includes an identifier to identify it as a native code query, along with the function its
attempting to call and optionally some arguments. When a `queryNativeCode` is called, the browser intercepts the prompt via a
`WKScriptMessageHandler`. It then determines which function to call, decodes the arguments, and runs the completion handler with
the returned result.

Since the `prompt` function is synchronous and blocks execution until its completion handler is executed, it allows for
easy request-response requests from JavaScript to Swift.
</details> 

Task 3: Basic parsing is located at `/Extensions/Sources/ExtensionsModel/FirefoxExtension+Decoding.swift`. To parse, it:
1. Downloads and unzips the XPI
2. Reads the manifest.json as a `[String: Any]`
3. Decodes all the required properties from the JSON

Task 4: The browser uses a `WKDownloadDelegate` to download the XPI, at `/Orion/UI/WebContent/NavigatorWebView/NavigatorWebView+WKDownloadDelegate.swift`.
The download process is:
1. Use the FireFox UA to get the "Add to Firefox" button showing
2. When the user clicks on the Add to Firefox button, tell WebKit to download the file in the extensions directory
3. When the download is complete, ask the ExtensionManager to decode the XPI (see `Task 3` above)
4. After the firefox extension is expanded, a Combine publisher event is sent and the new extension is added to the toolbar

<details>
<summary>Rendering the popup</summary>
When the raw file:// url is used, there are issues.

**Problem**:
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

**Solution**:
WebKit has a  `loadFileURL` function that takes an optional `allowingReadAccessTo` URL. However, this approach
did not work.

My solution uses a custom URL scheme, namely `firefox-extension`. The file url above would translate to
`firefox-extension://[extension id]/popup/panel.html`. The ``ExtensionWebViewController``
intercepts this request via `WKURLSchemeHandler`, and supplies webkit with the contents of the correct file.

In this new system, `<script src="/popup/panel.js"></script>` would be correctly loaded as
`firefox-extension://[extension id]/popup/panel.js`.
</details>

Task 5: The custom URL change navigation delegate method is located at `Orion/UI/WebContent/NavigatorWebView/NavigatorWebView+NavigationDelegate.swift`.
To detect the change in URL, a `NSKeyValueObservation` is added to the `url` of the web view. Whenever the URL changes,
the `webView(_:urlChange:)` function of `WKNavigationDelegatePlus` (a protocol extending WKNavigationDelegate) is triggered.

There is a similar function that detects the change in title, which is used to keep the titles in the `TopSites` API accurate.

## macOS 10.13+ Compatibility (Task 6)
TODO

## Largest challenges and how I solved them (Task 7)
TODO
