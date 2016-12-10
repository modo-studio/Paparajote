import Foundation
import Quick
import Nimble
import NSURL_QueryDictionary

@testable import Paparajote

class UnsplashProviderSpec: QuickSpec {
    
    override func spec() {
        var subject: UnsplashProvider!
        var clientId: String!
        var clientSecret: String!
        var redirectUri: String!
        var scope: [String]!
        
        beforeEach {
            clientId = "client_id"
            clientSecret = "client_secret"
            redirectUri = "redirect://works"
            scope = ["scope1", "scope2"]
            subject = UnsplashProvider(clientId: clientId,
                                       clientSecret: clientSecret,
                                       redirectUri: redirectUri,
                                       scope: scope)
        }
        
        describe("-authorization") {
            it("should return the correct url") {
                let expected = "https://unsplash.com/oauth/authorize?response_type=code&scope=scope1%2Bscope2&redirect_uri=redirect%3A%2F%2Fworks&client_id=client_id"
                expect(subject.authorization().absoluteString) == expected
            }
        }
        
        describe("-authentication") {
            context("when there's no code in the url") {
                it("should return nil") {
                    let url = URL(string: "\(redirectUri!)?state=abc")!
                    expect(subject.authentication(url)).to(beNil())
                }
            }
            
            context("when it has code and state") {
                var request: URLRequest!
                
                beforeEach {
                    let url = URL(string: "\(redirectUri!)?code=abc&state")!
                    request = subject.authentication(url)
                }
                
                it("should return a request with the correct URL") {
                    let expected = "https://unsplash.com/oauth/token?client_secret=client_secret&grant_type=authorization_code&code=abc&client_id=client_id&redirect_uri=redirect%3A%2F%2Fworks"
                    expect(request.url?.absoluteString) == expected
                }
                
                it("should return a request with the a JSON Accept header") {
                    expect(request.value(forHTTPHeaderField: "Accept")) == "application/json"
                }
                
                it("should return a request with the POST method") {
                    expect(request.httpMethod) == "POST"
                }
            }
        }
        
        
        describe("-sessionAdapter") {
            context("when the data has not the correct format") {
                it("should return nil") {
                    let dictionary: [String: Any] = [:]
                    let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
                    expect(subject.sessionAdapter(data, URLResponse())).to(beNil())
                }
            }
            context("when the data has the correct format") {
                it("should return the session") {
                    let dictionary = ["access_token": "tooooken"]
                    let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
                    expect(subject.sessionAdapter(data, URLResponse())?.accessToken) == "tooooken"
                }
            }
        }
    }
    
}
