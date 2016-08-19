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
                let expected = OAuth2Event.Open(url: NSURL(string: "test://authorization")!)
                expect(delegate.receivedEvent) == expected
            }
            
            it("should assert if we try to start the flow once started") {
                expect {
                    try subject.start()
                }.to(throwError(OAuth2Error.AlreadyStarted))
            }
        }
        
        describe("-shouldRedirect:url:") {

            it("should return if the the authentication request is not generated") {
                subject.shouldRedirect(url: NSURL(string: "test://test")!)
                expect(service.called) == false
            }
            
            context("when the entity returns an authentication request") {
                
                beforeEach {
                    provider = MockProvider(authenticationRequest: NSURLRequest(URL: NSURL(string: "test://")!), session: nil)
                    subject = OAuth2Controller(provider: provider, delegate: delegate, service: service)
                }
                
                it("should execute the request") {
                    subject.shouldRedirect(url: NSURL(string: "test://test")!)
                    expect(service.called) == true
                }
                
                it("should notify the delegate that there's no response") {
                    subject.shouldRedirect(url: NSURL(string: "test://test")!)
                    expect(delegate.receivedEvent) == OAuth2Event.Error(OAuth2Error.NoResponse)
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
                        subject.shouldRedirect(url: NSURL(string: "test://test")!)
                        expect(delegate.receivedEvent) == OAuth2Event.Error(error)
                    }
                }
                
                context("when the service returns data") {
                    beforeEach {
                        service = MockService(data: NSData(), response: NSURLResponse())
                    }
                    
                    context("and the session can be parsed") {
                        var session: OAuth2Session!
                        
                        beforeEach {
                            session = OAuth2Session(accessToken: "token", refreshToken: "refresh")
                            provider = MockProvider(authenticationRequest: NSURLRequest(URL: NSURL(string: "test://")!), session: session)
                            subject = OAuth2Controller(provider: provider, delegate: delegate, service: service)
                        }
                        
                        it("should notify the delegate about the new session") {
                            subject.shouldRedirect(url: NSURL(string: "test://test")!)
                            expect(delegate.receivedEvent) == OAuth2Event.Session(session)
                        }
                    }
                    
                    context("and the session cannot be parsed") {
                        
                        beforeEach {
                            provider = MockProvider(authenticationRequest: NSURLRequest(URL: NSURL(string: "test://")!), session: nil)
                            subject = OAuth2Controller(provider: provider, delegate: delegate, service: service)
                        }
                        
                        it("should notify the delegate about the new session") {
                            subject.shouldRedirect(url: NSURL(string: "test://test")!)
                            expect(delegate.receivedEvent) == OAuth2Event.Error(OAuth2Error.SessionNotFound)
                        }
                    }
                }
                
            }
        }
        
    }
}


// MARK: - Mocks

private struct MockProvider: OAuth2Provider {
    
    private let authenticationRequest: NSURLRequest!
    private let session: OAuth2Session!
    
    init(authenticationRequest: NSURLRequest! = nil, session: OAuth2Session! = nil) {
        self.authenticationRequest = authenticationRequest
        self.session = session
    }
    
    var authorization: Authorization = {
        return NSURL(string: "test://authorization")!
    }
    
    var authentication: Authentication {
        return { (url: NSURL) -> NSURLRequest? in
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
    
    private func oauth(event event: OAuth2Event) {
        self.receivedEvent = event
    }
    
}

private class MockService: Service {
    
    var called: Bool = false
    var data: NSData!
    var response: NSURLResponse!
    var error: NSError!
    
    init(data: NSData! = nil, response: NSURLResponse! = nil, error: NSError! = nil) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    private override func execute(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        self.called = true
        completionHandler(self.data, self.response, self.error)
    }

}