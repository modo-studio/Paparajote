import Foundation

/**
 *  Represents an OAuth2 session
 */
public struct Session {
    
    // MARK: - Attributes
    
    /// Session access token.
    public var accessToken: String
    
    /// Session refresh token.
    public var refreshToken: String?
    
}