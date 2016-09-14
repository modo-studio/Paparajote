import Foundation
import Quick
import Nimble
import NSURL_QueryDictionary

@testable import Paparajote

class GitHubProviderSpec: QuickSpec {
    
    override func spec() {
        var subject: GitHubProvider!
        var clientId: String!
        var clientSecret: String!
        var redirectUri: String!
        var allowSignup: Bool!
        var scope: [String]!
        var state: String!
        
        beforeEach {
            clientId = "client_id"
            clientSecret = "client_secret"
            redirectUri = "redirect://works"
            allowSignup = true
            scope = ["scope1"]
            state = "asdg135125"
            subject = GitHubProvider(clientId: clientId,
                clientSecret: clientSecret,
                redirectUri: redirectUri,
                allowSignup: allowSignup,
                scope: scope,
                state: state)
        }
        
        describe("-authorization") {
            it("should return the correct url") {
                let expected = "https://github.com/login/oauth/authorize?scope=scope1&allow_signup=true&client_id=client_id&state=asdg135125"
                expect(subject.authorization().absoluteString) == expected
            }
        }
        
        describe("-authentication") {
            context("when there's no code in the url") {
                it("should return nil") {
                    let url = NSURL(string: "\(redirectUri)?state=abc")!
                    expect(subject.authentication(url)).to(beNil())
                }
            }
            context("when there's no state in the url") {
                it("should return nil") {
                    let url = NSURL(string: "\(redirectUri)?code=abc")!
                    expect(subject.authentication(url)).to(beNil())
                }
            }
            
            context("when it has code and state") {
                var request: NSURLRequest!
                
                beforeEach {
                    let url = NSURL(string: "\(redirectUri)?code=abc&state=\(state)")!
                    request = subject.authentication(url)
                }
                
                it("should return a request with the correct URL") {
                    let expected = "https://github.com/login/oauth/access_token?state=asdg135125&redirect_uri=redirect%3A%2F%2Fworks&client_secret=client_secret&client_id=client_id&code=abc"
                    expect(request.URL?.absoluteString) == expected
                }
                
                it("should return a request with the a JSON Accept header") {
                    expect(request.valueForHTTPHeaderField("Accept")) == "application/json"
                }
                
                it("should return a request with the POST method") {
                    expect(request.HTTPMethod) == "POST"
                }
            }
        }
        
        
        describe("-sessionAdapter") {
            context("when the data has not the correct format") {
                it("should return nil") {
                    let dictionary = [:]
                    let data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
                    expect(subject.sessionAdapter(data, NSURLResponse())).to(beNil())
                }
            }
            context("when the data has the correct format") {
                it("should return the session") {
                    let dictionary = ["access_token": "tooooken"]
                    let data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
                    expect(subject.sessionAdapter(data, NSURLResponse())?.accessToken) == "tooooken"
                }
            }
        }
    }
    
}