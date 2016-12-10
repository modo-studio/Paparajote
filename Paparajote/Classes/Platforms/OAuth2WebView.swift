#if os(iOS)

import Foundation
import UIKit

/// OAuth2 WebView
public class OAuth2WebView: UIWebView {

    // MARK: - Attributes

    internal var oauthDelegate: OAuth2WebViewDelegate!

    // MARK: - Init

    /**
     Initializes the OAuth2WebView

     - parameter frame:      UIWebView frame.
     - parameter provider:   OAuth2 provider.
     - parameter completion: OAuth2 completion.

     - throws: Throws an error if the OAuth2 flow cannot be started.

     - returns: Initialized OAuth2WebView.
     */
    public init(frame: CGRect,
                provider: OAuth2Provider,
                completion: @escaping OAuth2SessionCompletion) throws {
        super.init(frame: frame)
        self.oauthDelegate = OAuth2WebViewDelegate(provider: provider, webView: self, completion: completion)
        try self.oauthDelegate.start()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

#endif
