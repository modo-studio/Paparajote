import Foundation

/**
 OAuth2 Error

 - AlreadyStarted:  Trying to tart the authentication when it was already started.
 - NoResponse:      We didn't get any response when trying to authenticate the user.
 - SessionNotFound: The session couldn't be found from the authentication endpoint response.
 */
public enum OAuth2Error: ErrorType {
    case AlreadyStarted
    case NoResponse
    case SessionNotFound
}

// MARK: - CustomStringConvertible

extension OAuth2Error: CustomStringConvertible {

    public var description: String {
        switch self {
        case .AlreadyStarted:
            return "Oauth2 flow already started."
        case .NoResponse:
            return "No response from the provider."
        case .SessionNotFound:
            return "Session not found"
        }
    }

}
