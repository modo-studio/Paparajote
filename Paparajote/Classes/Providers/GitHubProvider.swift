import Foundation
import NSURL_QueryDictionary

public struct GitHubProvider: OAuth2Provider {

    // MARK: - Attributes

    fileprivate let clientId: String
    fileprivate let clientSecret: String
    fileprivate let redirectUri: String
    fileprivate let scope: [String]
    fileprivate let state: String
    fileprivate let allowSignup: Bool

    // MARK: - Init

    public init(clientId: String, clientSecret: String, redirectUri: String, allowSignup: Bool = true, scope: [String] = [], state: String = String.random()) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.allowSignup = allowSignup
        self.scope = scope
        self.state = state
    }

    // MARK: - Oauth2Provider

    public var authorization: Authorization {
        get {
            return { () -> URL in
                var allowSignUpString = "false"
                if self.allowSignup {
                    allowSignUpString = "true"
                }
                return (URL(string: "https://github.com/login/oauth/authorize")! as NSURL)
                    .uq_URL(byAppendingQueryDictionary: [
                        "client_id": self.clientId,
                        "state": self.state,
                        "scope": self.scope.joined(separator: " "),
                        "allow_signup": allowSignUpString
                    ])
            }
        }
    }

    public var authentication: Authentication {
        get {
            return { url -> URLRequest? in
                if !url.absoluteString.contains(self.redirectUri) { return nil }
                guard let code = (url as NSURL).uq_queryDictionary()["code"] as? String,
                    let state = (url as NSURL).uq_queryDictionary()["state"] as? String else { return nil }
                if state != self.state { return nil }
                let authenticationUrl: URL = (URL(string: "https://github.com/login/oauth/access_token")! as NSURL)
                    .uq_URL(byAppendingQueryDictionary: [
                        "client_id" : self.clientId,
                        "client_secret": self.clientSecret,
                        "code": code,
                        "redirect_uri": self.redirectUri,
                        "state": self.state
                    ])
                let request = NSMutableURLRequest()
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpMethod = "POST"
                request.url = authenticationUrl
                return request.copy() as? URLRequest
            }
        }
    }

    public var sessionAdapter: SessionAdapter = { (data,  _) -> OAuth2Session? in
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: String] else { return nil }
        return dictionary["access_token"].map {OAuth2Session(accessToken: $0, refreshToken: nil)}
    }

}
