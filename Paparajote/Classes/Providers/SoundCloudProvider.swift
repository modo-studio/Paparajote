import Foundation
import NSURL_QueryDictionary

public struct SoundCloudProvider: OAuth2Provider {

    // MARK: - Attributes

    private let clientId: String //client_id
    private let clientSecret: String //client_secret
    private let redirectUri: String //redirect_uri
    private let responseType: String = "code" //response_type
    private let scope: String = "*" //scope
    private let display: String = "popup" //display
    private let state: String //state

    // MARK: - Init

    public init(clientId: String, clientSecret: String, redirectUri: String, state: String = String.random()) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.state = state
    }

    // MARK: - Oauth2Provider

    public var authorization: Authorization {
        get {
            return { () -> NSURL in
                return NSURL(string: "https://soundcloud.com/connect")!
                    .uq_URLByAppendingQueryDictionary([
                        "client_id": self.clientId,
                        "redirect_uri": self.redirectUri,
                        "response_type": self.responseType,
                        "scope": self.scope,
                        "display": self.display,
                        "state": self.state
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
                let authenticationUrl: NSURL = NSURL(string: "https://api.soundcloud.com/oauth2/token")!
                    .uq_URLByAppendingQueryDictionary([
                        "client_id" : self.clientId,
                        "client_secret": self.clientSecret,
                        "code": code,
                        "redirect_uri": self.redirectUri,
                        "grant_type": "authorization_code"
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
