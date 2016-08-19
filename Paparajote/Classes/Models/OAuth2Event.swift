import Foundation

/**
 OAuth2 Event

 - Open:    The url must be opened in a web browser.
 - Error:   There was an error during the authentication flow.
 - Session: User was authenticated and the session is provided.
 */
public enum OAuth2Event: Equatable {
    case Open(url: NSURL)
    case Error(ErrorType)
    case Session(OAuth2Session)
}

// MARK: - <Equatable>

public func == (lhs: OAuth2Event, rhs: OAuth2Event) -> Bool {
    switch lhs {
    case .Open(let lhsUrl):
        switch rhs {
        case .Open(let rhsUrl):
            return lhsUrl == rhsUrl
        default:
            return false
        }
    case .Error(let lhsError):
        switch rhs {
        case .Error(let rhsError):
            if let lhsEquatableError = lhsError as? NSError,
                rhsEquatableError = rhsError as? NSError {
                return lhsEquatableError == rhsEquatableError
            }
            return false
        default:
            return false
        }
    case .Session(let lhsSession):
        switch rhs {
        case .Session(let rhsSession):
            return lhsSession == rhsSession
        default:
            return false
        }
    }
}
