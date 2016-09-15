import Foundation
import NSURL_QueryDictionary

public struct GitHubProvider: OAuth2Provider {

    // MARK: - Attributes

    private let clientId: String
    private let clientSecret: String
    private let redirectUri: String
    private let scope: [String]
    private let state: String
    private let allowSignup: Bool

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
            return { () -> NSURL in
                return NSURL(string: "https://github.com/login/oauth/authorize")!
                    .uq_URLByAppendingQueryDictionary([
                        "client_id": self.clientId,
                        "state": self.state,
                        "scope": self.scope.joinWithSeparator(" "),
                        "allow_signup": self.allowSignup ? "true": "false"
                    ])
            }
        }
    }
    public var authentication: Authentication {
        get {
            return { url -> NSURLRequest? in
                if !url.absoluteString.containsString(self.redirectUri) { return nil }
                guard let code = url.uq_queryDictionary()["code"] as? String,
                    let state = url.uq_queryDictionary()["state"] as? String else { return nil }
                if state != self.state { return nil }
                let authenticationUrl: NSURL = NSURL(string: "https://github.com/login/oauth/access_token")!
                    .uq_URLByAppendingQueryDictionary([
                        "client_id" : self.clientId,
                        "client_secret": self.clientSecret,
                        "code": code,
                        "redirect_uri": self.redirectUri,
                        "state": self.state
                    ])
                let request = NSMutableURLRequest()
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.HTTPMethod = "POST"
                request.URL = authenticationUrl
                return request.copy() as? NSURLRequest
            }
        }
    }

    public var sessionAdapter: SessionAdapter = { (data,  _) -> OAuth2Session? in
        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
        guard let dictionary = json as? [String: String] else { return nil }
        return dictionary["access_token"].map {OAuth2Session(accessToken: $0, refreshToken: nil)}
    }

}
