import Foundation

/**
 OAuth2 Event

 - open:    The url must be opened in a web browser.
 - error:   There was an error during the authentication flow.
 - session: User was authenticated and the session is provided.
 */
public enum OAuth2Event: Equatable {
    case open(url: URL)
    case error(Error)
    case session(OAuth2Session)
}

// MARK: - <Equatable>

public func == (lhs: OAuth2Event, rhs: OAuth2Event) -> Bool {
    switch lhs {
    case .open(let lhsUrl):
        switch rhs {
        case .open(let rhsUrl):
            return lhsUrl == rhsUrl
        default:
            return false
        }
    case .error(let lhsError):
        switch rhs {
        case .error(let rhsError):
            if let lhsEquatableError = lhsError as? NSError,
                let rhsEquatableError = rhsError as? NSError {
                return lhsEquatableError == rhsEquatableError
            }
            return false
        default:
            return false
        }
    case .session(let lhsSession):
        switch rhs {
        case .session(let rhsSession):
            return lhsSession == rhsSession
        default:
            return false
        }
    }
}
