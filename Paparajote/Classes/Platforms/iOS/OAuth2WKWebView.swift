#if os(iOS)

import Foundation
import UIKit
import WebKit

/// OAuth2 WKWebView
public class OAuth2WKWebView: WKWebView {

    // MARK: - Attributes

    internal var oauthDelegate: OAuth2WKNavigationDelegate!

    // MARK: - Init

    /**
     Initializes the OAuth2WebView

     - parameter frame:      UIWebView frame.
     - parameter provider:   OAuth2 provider.
     - parameter completion: OAuth2 completion.

     - throws: Throws an error if the OAuth2 flow cannot be started.

     - returns: Initialized OAuth2WebView.
     */
    public init(frame: CGRect, provider: OAuth2Provider, completion: OAuth2SessionCompletion) throws {
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        self.oauthDelegate = OAuth2WKNavigationDelegate(provider: provider, webView: self, completion: completion)
        try self.oauthDelegate.start()
    }

}

#endif
