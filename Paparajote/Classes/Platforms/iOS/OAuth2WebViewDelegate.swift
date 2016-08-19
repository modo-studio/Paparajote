#if os(iOS)

import Foundation
import UIKit

public typealias SessionCompletion = (OAuth2Session?, ErrorType?) -> ()

@objc public class OAuth2WebviewDelegate: NSObject, UIWebViewDelegate, OAuth2Delegate {

    // MARK: - Attributes

    private let provider: OAuth2Provider
    private let sessionCompletion: SessionCompletion
    private var controller: OAuth2Controller!
    private weak var webView: UIWebView?

    // MARK: - Init

    public init(provider: OAuth2Provider, webView: UIWebView, sessionCompletion: SessionCompletion) {
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
