import Foundation
import Quick
import Nimble
import NSURL_QueryDictionary

@testable import Paparajote

class GitLabProviderSpec: QuickSpec {
    
    override func spec() {
        var subject: GitLabProvider!
        var clientId: String!
        var clientSecret: String!
        var redirectUri: String!
        var state: String!
        var url: URL!
    
        beforeEach {
            clientId = "client_id"
            clientSecret = "client_secret"
            redirectUri = "redirect://works"
            state = "asdg135125"
            url = URL(string: "https://gitlab.com")!
            subject = GitLabProvider(url: url, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri, state: state)
        }
        
        describe("-authorization") {
            it("should return the correct url") {
                let expected = "https://gitlab.com/oauth/authorize?client_id=client_id&redirect_uri=redirect://works&response_type=code&state=asdg135125"
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
            context("when there's no state in the url") {
                it("should return nil") {
                    let url = URL(string: "\(redirectUri!)?code=abc")!
                    expect(subject.authentication(url)).to(beNil())
                }
            }
            
            context("when it has code and state") {
                var request: URLRequest!
                
                beforeEach {
                    let url = URL(string: "\(redirectUri!)?code=abc&state=\(state!)")!
                    request = subject.authentication(url)
                }
                
                it("should return a request with the correct URL") {
                    let expected = "https://gitlab.com/oauth/token?client_id=client_id&client_secret=client_secret&code=abc&grant_type=authorization_code"
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
