import Foundation

/// OAuth2 delegate.
public protocol OAuth2Delegate: class {
    /**
     New OAuth2Event that has to be processed to continue with the OAuth2 flow.

     - parameter event: Eventn to be processed.
     */
    func oauth(event: OAuth2Event)

}
