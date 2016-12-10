import Foundation

/**
 OAuth2 Error

 - AlreadyStarted:  Trying to tart the authentication when it was already started.
 - NoResponse:      We didn't get any response when trying to authenticate the user.
 - SessionNotFound: The session couldn't be found from the authentication endpoint response.
 */
public enum OAuth2Error: Error {
    case alreadyStarted
    case noResponse
    case sessionNotFound
}

// MARK: - CustomStringConvertible

extension OAuth2Error: CustomStringConvertible {

    public var description: String {
        switch self {
        case .alreadyStarted:
            return "Oauth2 flow already started."
        case .noResponse:
            return "No response from the provider."
        case .sessionNotFound:
            return "Session not found"
        }
    }

}
