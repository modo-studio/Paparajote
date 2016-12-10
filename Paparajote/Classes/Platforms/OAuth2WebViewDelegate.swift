#if os(iOS)

import Foundation
import UIKit

/// UIWebView delegate object that handles the OAuth2 login.
@objc public class OAuth2WebViewDelegate: NSObject, UIWebViewDelegate, OAuth2Delegate {

    // MARK: - Attributes

    internal let provider: OAuth2Provider
    internal let completion: OAuth2SessionCompletion
    internal var controller: OAuth2Controller!
    internal weak var webView: UIWebView?

    // MARK: - Init

    /**
     Initializes the OAuth2WebViewDelegate.

     - parameter provider:          OAuth2 provider.
     - parameter webView:           UIWebview where the authentication will be loaded.
     - parameter completion: Callback to notify about the OAuth2 completion.

     - returns: Initialized OAuth2WebViewDelegate instance.
     */
    public init(provider: OAuth2Provider,
                webView: UIWebView,
                completion: @escaping OAuth2SessionCompletion) {
        self.provider = provider
        self.webView = webView
        self.completion = completion
        super.init()
        self.webView?.delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    /**
     Starts the OAuth2 flow.

     - throws: An error if this method is called once the flow has started.
     */
    public func start() throws {
        if self.controller == nil {
            self.controller = OAuth2Controller(provider: provider, delegate: self)
        }
        try self.controller.start()
    }

    // MARK: - <OAuth2Delegate>

    public func oauth(event: OAuth2Event) {
        switch event {
        case .error(let error):
            self.completion(nil, error)
        case .open(let url):
            self.webView?.loadRequest(URLRequest(url: url))
        case .session(let session):
            self.completion(session, nil)
        }
    }

    // MARK: - <UIWebViewDelegate>
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return self.controller.shouldRedirect(url: request.url!) 
    }

}

#endif
