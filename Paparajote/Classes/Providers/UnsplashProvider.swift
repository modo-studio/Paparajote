import Foundation
import NSURL_QueryDictionary

public struct UnsplashProvider: OAuth2Provider {
    
    // MARK: - Attributes
    
    fileprivate let clientId: String
    fileprivate let clientSecret: String
    fileprivate let redirectUri: String
    fileprivate let scope: [String]
    fileprivate let responseType: String = "code"
    
    // MARK: - Init
    
    public init(clientId: String,
                clientSecret: String,
                redirectUri: String,
                scope: [String] = []) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.scope = scope
    }
    
    // MARK: - Oauth2Provider
    
    /// Provider authorization.
    public var authorization: Authorization {
        get {
            return { () -> URL in
                return (URL(string: "https://unsplash.com/oauth/authorize")! as NSURL)
                    .uq_URL(byAppendingQueryDictionary: [
                        "client_id": self.clientId,
                        "redirect_uri": self.redirectUri,
                        "response_type": self.responseType,
                        "scope": self.scope.joined(separator: "+")
                        ])
            }
        }
    }

    /// Provider authentication.
    public var authentication: Authentication {
        get {
            return { url -> URLRequest? in
                if !url.absoluteString.contains(self.redirectUri) { return nil }
                guard let code = (url as NSURL).uq_queryDictionary()["code"] as? String else { return nil }
                let authenticationUrl: URL = (URL(string: "https://unsplash.com/oauth/token")! as NSURL)
                    .uq_URL(byAppendingQueryDictionary: [
                        "client_id" : self.clientId,
                        "client_secret": self.clientSecret,
                        "code": code,
                        "redirect_uri": self.redirectUri,
                        "grant_type": "authorization_code"
                        ])
                let request = NSMutableURLRequest()
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpMethod = "POST"
                request.url = authenticationUrl
                return request.copy() as? URLRequest
            }
        }
    }

    /// Provider session adapter.
    public var sessionAdapter: SessionAdapter = { (data,  _) -> OAuth2Session? in
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: String] else { return nil }
        return dictionary["access_token"].map {OAuth2Session(accessToken: $0, refreshToken: nil)}
    }
    
}
