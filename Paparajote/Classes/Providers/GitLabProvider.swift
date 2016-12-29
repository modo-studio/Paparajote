import Foundation
import NSURL_QueryDictionary

public struct GitLabProvider: OAuth2Provider {

    // MARK: - Attributes

    fileprivate let clientId: String
    fileprivate let clientSecret: String
    fileprivate let redirectUri: String
    fileprivate let state: String
    fileprivate let url: URL

    // MARK: - Init

    public init(url: URL = URL(string: "https://gitlab.com")!,
                clientId: String,
                clientSecret: String,
                redirectUri: String,
                state: String = String.random()) {
        self.url = url
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.state = state
    }

    // MARK: - Oauth2Provider

    public var authorization: Authorization {
        get {
            return { () -> URL in
                var components = URLComponents(url: self.url, resolvingAgainstBaseURL: false)!
                components.path = "/oauth/authorize"
                components.queryItems = [
                    URLQueryItem(name: "client_id", value: self.clientId),
                    URLQueryItem(name: "redirect_uri", value: self.redirectUri),
                    URLQueryItem(name: "response_type", value: "code"),
                    URLQueryItem(name: "state", value: self.state)
                ]
                return components.url!
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
                var components = URLComponents(url: self.url, resolvingAgainstBaseURL: false)!
                components.path = "/oauth/token"
                components.queryItems = [
                    URLQueryItem(name: "client_id", value: self.clientId),
                    URLQueryItem(name: "client_secret", value: self.clientSecret),
                    URLQueryItem(name: "code", value: code),
                    URLQueryItem(name: "redirect_uri", value: self.redirectUri),
                    URLQueryItem(name: "grant_type", value: "authorization_code")
                ]
                let request = NSMutableURLRequest()
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpMethod = "POST"
                request.url = components.url!
                return request.copy() as? URLRequest
            }
        }
    }

    public var sessionAdapter: SessionAdapter = { (data,  _) -> OAuth2Session? in
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: Any] else { return nil }
        let token = dictionary["access_token"] as? String
        let refresh = dictionary["refresh_token"] as? String
        return token.map {OAuth2Session(accessToken: $0, refreshToken: refresh)}
    }
}
