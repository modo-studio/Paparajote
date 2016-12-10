import Foundation
import Quick
import Nimble

@testable import Paparajote

class SoundCloudProviderSpec: QuickSpec {
    override func spec() {
        
        var clientId: String!
        var clientSecret: String!
        var redirectUri: String!
        var responseType: String!
        var scope: String!
        var display: String!
        var state: String!
        var subject: SoundCloudProvider!
        
        beforeEach {
            clientId = "clientid"
            clientSecret = "clientsecret"
            redirectUri = "test://test"
            responseType = "responsetype"
            scope = "scope"
            display = "display"
            state = "state"
            subject = SoundCloudProvider(clientId: clientId,
                clientSecret: clientSecret,
                redirectUri: redirectUri,
                state: state)
        }
        
        describe("-authorization") {
            it("it should return the corret url") {
                expect(subject.authorization().absoluteString) == "https://soundcloud.com/connect?state=state&response_type=code&display=popup&scope=%2A&redirect_uri=test%3A%2F%2Ftest&client_id=clientid"
            }
        }
        
        describe("-authentication") {
            context("when the redirect uri is invalid") {
                it("should return nil") {
                    let url = URL(string: "xasdgas")!
                    expect(subject.authentication(url)).to(beNil())
                }
            }
            context("when there's no code") {
                it("should return nil") {
                    let url = URL(string: "test://test?state=123")!
                    expect(subject.authentication(url)).to(beNil())
                }
            }
            context("when there's no state") {
                it("should return nil") {
                    let url = URL(string: "test://test?code=123")!
                    expect(subject.authentication(url)).to(beNil())
                }
            }
            context("when there's code and state but the state doesn't match") {
                it("should return nil") {
                    let url = URL(string: "test://test?code=123&state=cc")!
                    expect(subject.authentication(url)).to(beNil())
                }
            }
            context("when all the data is valid") {
                var request: URLRequest!
                
                beforeEach {
                    let url = URL(string: "test://test?code=123&state=state")!
                    request = subject.authentication(url)
                }
                
                it("should have the correct url") {
                    expect(request.url?.absoluteString) == "https://api.soundcloud.com/oauth2/token?client_secret=clientsecret&grant_type=authorization_code&code=123&client_id=clientid&redirect_uri=test%3A%2F%2Ftest"
                }
                
                it("should have the correct HTTP method") {
                    expect(request.httpMethod) == "POST"
                }
                
                it("should have the correct Accept header") {
                    expect(request.value(forHTTPHeaderField: "Accept")) == "application/json"
                }
            }
        }
        
        describe("-sessionAdapter") {
            it("should return nil if there's no access token") {
                let data = try! JSONSerialization.data(withJSONObject: ["asga": "asdga"], options: [])
                expect(subject.sessionAdapter(data, URLResponse())).to(beNil())
            }
            it("should return a session with the right access token if there's token") {
                let data = try! JSONSerialization.data(withJSONObject: ["access_token": "asdga"], options: [])
                expect(subject.sessionAdapter(data, URLResponse())?.accessToken) == "asdga"
            }
        }
    }
}
