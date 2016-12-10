import Foundation

/**
 OAuth2 Event

 - Open:    The url must be opened in a web browser.
 - Error:   There was an error during the authentication flow.
 - Session: User was authenticated and the session is provided.
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
            return lhsError as NSError == rhsError as NSError
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
