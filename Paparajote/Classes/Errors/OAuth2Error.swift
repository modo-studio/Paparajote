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
            return "The OAuth2 has already been started. Wait until it completes before calling start again."
        case .NoResponse:
            return "We couldn't get a valid response from the provider"
        case .SessionNotFound:
            return "Session couldn't be found"
        }
    }

}
