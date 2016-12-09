import Foundation

/// Returns the url to start the authorizzation flow.
public typealias Authorization = () -> URL

/// Given a redirection URL, if it contains the authentication token, this method should return the request for authenticating the user.
public typealias Authentication = (URL) -> URLRequest?

/// The adapter tries to fetch the session from the authentication response.
public typealias SessionAdapter = (Data, URLResponse) -> OAuth2Session?

public protocol OAuth2Provider {

    /// Provider authorization.
    var authorization: Authorization { get }

    /// Provider authentication.
    var authentication: Authentication { get }

    /// Provider session adapter.
    var sessionAdapter: SessionAdapter { get }

}
