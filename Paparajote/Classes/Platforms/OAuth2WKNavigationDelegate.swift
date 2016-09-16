#if os(iOS) || os(OSX)
import Foundation
import WebKit

/// WKNavigationDelegate that handles the OAuth2 flow.
@available(OSX 10.10, *)
@objc public class OAuth2WKNavigationDelegate: NSObject, WKNavigationDelegate, OAuth2Delegate {

    // MARK: - Attributes

    private let provider: OAuth2Provider
    private var controller: OAuth2Controller!
    private weak var webView: WKWebView?
    private let completion: OAuth2SessionCompletion

    // MARK: - Init

    /**
     Initializes the OAuth2WKNavigationDelegate.

     - parameter provider:   OAuth2 provider.
     - parameter webView:    WKWebView where the authentication will be loaded.
     - parameter completion: Callback to notify about the OAuth2 completion.

     - returns: Initialized instance of OAuth2WKNavigationDelegate.
     */
    internal init(provider: OAuth2Provider, webView: WKWebView, completion: OAuth2SessionCompletion) {
        self.provider = provider
        self.webView = webView
        self.completion = completion
    }

    // MARK: - Public

    /**
     Starts the OAuth2 flow.

     - throws: It throws an exception if this method is called again once the flow has started.
     */
    public func start() throws {
        if self.controller == nil {
            self.controller = OAuth2Controller(provider: self.provider, delegate: self)
        }
        try self.controller.start()
    }

    // MARK: - <WKNavigationDelegate>

    public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.URL else {
            decisionHandler(WKNavigationActionPolicy.Allow)
            return
        }
        let shouldRedirect = self.controller.shouldRedirect(url: url)
        decisionHandler(shouldRedirect ? .Allow : .Cancel)
    }

    // MARK: - <OAuth2Delegate>

    public func oauth(event event: OAuth2Event) {
        switch event {
        case .Error(let error):
            self.completion(nil, error)
        case .Open(let url):
            self.webView?.loadRequest(NSURLRequest(URL: url))
        case .Session(let session):
            self.completion(session, nil)
        }
    }

}
#endif
