import Foundation

/// Returns the url to start the authorizzation flow.
public typealias Authorization = () -> NSURL

/// Given a redirection URL, if it contains the authentication token, this method should return the request for authenticating the user.
public typealias Authentication = NSURL -> NSURLRequest?

/// The adapter tries to fetch the session from the authentication response. If the session cannot be fetched. The adapter should throw an error.
public typealias SessionAdapter = (NSData, NSURLResponse) throws -> Session

public protocol Oauth2Provider {
    
    /// Provider authorization.
    var authorization: Authorization { get }
    
    /// Provider authentication.
    var authentication: Authentication { get }
    
    /// Provider session adapter.
    var sessionAdapter: SessionAdapter { get }
    
}