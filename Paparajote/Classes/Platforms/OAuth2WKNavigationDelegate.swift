#if os(iOS) || os(OSX)
import Foundation
import WebKit

/// WKNavigationDelegate that handles the OAuth2 flow.
@available(OSX 10.10, *)
@objc open class OAuth2WKNavigationDelegate: NSObject, WKNavigationDelegate, OAuth2Delegate {

    // MARK: - Attributes

    fileprivate let provider: OAuth2Provider
    fileprivate var controller: OAuth2Controller!
    fileprivate weak var webView: WKWebView?
    fileprivate let completion: OAuth2SessionCompletion

    // MARK: - Init

    /**
     Initializes the OAuth2WKNavigationDelegate.

     - parameter provider:   OAuth2 provider.
     - parameter webView:    WKWebView where the authentication will be loaded.
     - parameter completion: Callback to notify about the OAuth2 completion.

     - returns: Initialized instance of OAuth2WKNavigationDelegate.
     */
    internal init(provider: OAuth2Provider, webView: WKWebView, completion: @escaping OAuth2SessionCompletion) {
        self.provider = provider
        self.webView = webView
        self.completion = completion
    }

    // MARK: - Public

    /**
     Starts the OAuth2 flow.

     - throws: It throws an exception if this method is called again once the flow has started.
     */
    open func start() throws {
        if self.controller == nil {
            self.controller = OAuth2Controller(provider: self.provider, delegate: self)
        }
        try self.controller.start()
    }

    // MARK: - <WKNavigationDelegate>

    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        let shouldRedirect = self.controller.shouldRedirect(url: url)
        decisionHandler(shouldRedirect ? .allow : .cancel)
    }

    // MARK: - <OAuth2Delegate>

    open func oauth(event: OAuth2Event) {
        switch event {
        case .error(let error):
            self.completion(nil, error)
        case .open(let url):
            _ = self.webView?.load(URLRequest(url: url))
        case .session(let session):
            self.completion(session, nil)
        }
    }

}
#endif
