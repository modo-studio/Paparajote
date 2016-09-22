import Foundation
import Quick
import Nimble

@testable import Paparajote

class OAuth2ControllerSpec: QuickSpec {
    override func spec() {
        
        var subject: OAuth2Controller!
        var delegate: MockDelegate!
        var provider: MockProvider!
        var service: MockService!
        
        beforeEach {
            delegate = MockDelegate()
            provider = MockProvider()
            service = MockService()
            subject = OAuth2Controller(provider: provider, delegate: delegate, service: service)
        }
        
        describe("-start") {
            beforeEach {
                try! subject.start()
            }
            it("should notify the delegate") {
                let expected = OAuth2Event.open(url: URL(string: "test://authorization")!)
                expect(delegate.receivedEvent) == expected
            }
            
            it("should assert if we try to start the flow once started") {
                expect {
                    try subject.start()
                }.to(throwError(OAuth2Error.alreadyStarted))
            }
        }
        
        describe("-shouldRedirect:url:") {

            it("should return if the the authentication request is not generated") {
                _ = subject.shouldRedirect(url: URL(string: "test://test")!)
                expect(service.called) == false
            }
            
            context("when the entity returns an authentication request") {
                
                beforeEach {
                    provider = MockProvider(authenticationRequest: URLRequest(url: URL(string: "test://")!), session: nil)
                    subject = OAuth2Controller(provider: provider, delegate: delegate, service: service)
                }
                
                it("should execute the request") {
                    _ = subject.shouldRedirect(url: URL(string: "test://test")!)
                    expect(service.called) == true
                }
                
                it("should notify the delegate that there's no response") {
                    _ = subject.shouldRedirect(url: URL(string: "test://test")!)
                    expect(delegate.receivedEvent) == OAuth2Event.error(OAuth2Error.noResponse)
                }
                
                it("shouldn't assert if we try to start the flow again") {
                    expect {
                        try subject.start()
                    }.toNot(throwError())
                }
                
                context("when the service returns an error") {
                    
                    var error: NSError!
                    
                    beforeEach {
                        error = NSError(domain: "", code: -1, userInfo: nil)
                        service = MockService(error: error)
                        subject = OAuth2Controller(provider: provider, delegate: delegate, service: service)
                    }
                    
                    it("should notify the delegate about the error") {
                        _ = subject.shouldRedirect(url: URL(string: "test://test")!)
                        expect(delegate.receivedEvent) == OAuth2Event.error(error)
                    }
                }
                
                context("when the service returns data") {
                    beforeEach {
                        service = MockService(data: Data(), response: URLResponse())
                    }
                    
                    context("and the session can be parsed") {
                        var session: OAuth2Session!
                        
                        beforeEach {
                            session = OAuth2Session(accessToken: "token", refreshToken: "refresh")
                            provider = MockProvider(authenticationRequest: URLRequest(url: URL(string: "test://")!), session: session)
                            subject = OAuth2Controller(provider: provider, delegate: delegate, service: service)
                        }
                        
                        it("should notify the delegate about the new session") {
                            _ = subject.shouldRedirect(url: URL(string: "test://test")!)
                            expect(delegate.receivedEvent) == OAuth2Event.session(session)
                        }
                    }
                    
                    context("and the session cannot be parsed") {
                        
                        beforeEach {
                            provider = MockProvider(authenticationRequest: URLRequest(url: URL(string: "test://")!), session: nil)
                            subject = OAuth2Controller(provider: provider, delegate: delegate, service: service)
                        }
                        
                        it("should notify the delegate about the new session") {
                            _ =  subject.shouldRedirect(url: URL(string: "test://test")!)
                            expect(delegate.receivedEvent) == OAuth2Event.error(OAuth2Error.sessionNotFound)
                        }
                    }
                }
                
            }
        }
        
    }
}


// MARK: - Mocks

private struct MockProvider: OAuth2Provider {
    
    fileprivate let authenticationRequest: URLRequest!
    fileprivate let session: OAuth2Session!
    
    init(authenticationRequest: URLRequest! = nil, session: OAuth2Session! = nil) {
        self.authenticationRequest = authenticationRequest
        self.session = session
    }
    
    var authorization: Authorization = {
        return URL(string: "test://authorization")!
    }
    
    var authentication: Authentication {
        return { (url: URL) -> URLRequest? in
            return self.authenticationRequest
        }
    }
    
    var sessionAdapter: SessionAdapter {
        return { (data, response) -> OAuth2Session? in
            return self.session
        }
    }
    
}

private class MockDelegate: OAuth2Delegate {
    
    var receivedEvent: OAuth2Event!
    
    fileprivate func oauth(event: OAuth2Event) {
        self.receivedEvent = event
    }
    
}

private class MockService: Service {
    
    var called: Bool = false
    var data: Data!
    var response: URLResponse!
    var error: NSError!
    
    init(data: Data! = nil, response: URLResponse! = nil, error: NSError! = nil) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    private override func execute(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.called = true
        completionHandler(self.data, self.response, self.error)

    }
    
}
