#if os(iOS)

import Foundation
import UIKit

/// UIWebView delegate object that handles the OAuth2 login.
@objc public class OAuth2WebViewDelegate: NSObject, UIWebViewDelegate, OAuth2Delegate {

    // MARK: - Attributes

    private let provider: OAuth2Provider
    private let sessionCompletion: OAuth2SessionCompletion
    private var controller: OAuth2Controller!
    private weak var webView: UIWebView?

    // MARK: - Init

    /**
     Initializes the OAuth2WebViewDelegate.

     - parameter provider:          OAuth2 provider.
     - parameter webView:           UIWebview where the authentication will be loaded.
     - parameter sessionCompletion: Callback to notify about the OAuth2 completion.

     - returns: Initialized OAuth2WebViewDelegate instance.
     */
    public init(provider: OAuth2Provider, webView: UIWebView, sessionCompletion: OAuth2SessionCompletion) {
        self.provider = provider
        self.webView = webView
        self.sessionCompletion = sessionCompletion
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

    public func oauth(event event: OAuth2Event) {
        switch event {
        case .Error(let error):
            self.sessionCompletion(nil, error)
        case .Open(let url):
            self.webView?.loadRequest(NSURLRequest(URL: url))
        case .Session(let session):
            self.sessionCompletion(session, nil)
        }
    }

    // MARK: - <UIWebViewDelegate>

    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return self.controller.shouldRedirect(url: request.URL!) ?? true
    }
}

#endif
