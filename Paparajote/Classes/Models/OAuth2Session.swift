import Foundation

/**
 *  Represents an OAuth2 session
 */
public struct OAuth2Session: Equatable {

    // MARK: - Attributes

    /// Session access token.
    public var accessToken: String

    /// Session refresh token.
    public var refreshToken: String?

}

public func == (lhsSession: OAuth2Session, rhsSession: OAuth2Session) -> Bool {
    return lhsSession.accessToken == rhsSession.accessToken &&
    lhsSession.refreshToken == rhsSession.refreshToken
}
