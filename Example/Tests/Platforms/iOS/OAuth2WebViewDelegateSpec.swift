import Foundation
import Quick
import Nimble

@testable import Paparajote

class OAuth2WebViewDelegateSpec: QuickSpec {
    override func spec() {
        
        var subject: OAuth2WebViewDelegate!
        var provider: MockProvider!
        var webview: MockWebView!
        var completionError: ErrorType!
        var completionSession: OAuth2Session!
        
        beforeEach {
            provider = MockProvider()
            webview = MockWebView()
            subject = OAuth2WebViewDelegate(provider: provider, webView: webview, sessionCompletion: { (session, error) in
                completionError = error
                completionSession = session
            })
        }
        
        describe("-start") {
            
            beforeEach {
                try! subject.start()
            }
            
            it("should load the authorization request in the webview") {
                expect(webview.requestLoaded.URL) == NSURL(string: "test://test")!
            }
            
            it("shoudl throw an error if we try to start it once started") {
                expect {
                    try subject.start()
                }.to(throwError())
            }
            
            it("should set the correct delegate") {
                expect(subject.controller.delegate).to(beIdenticalTo(subject))
            }
        }
        
        describe("-oauth:event:") {
            
            context("when an error is sent") {
                
                var error: OAuth2Error!
                
                beforeEach {
                    error = OAuth2Error.AlreadyStarted
                    subject.oauth(event: OAuth2Event.Error(error))
                }
                
                it("should send the error to the completion closure") {
                    expect(error) == completionError as! OAuth2Error
                }
            }
            
            context("when a session is sent") {
                var session: OAuth2Session!
                beforeEach {
                    session = OAuth2Session(accessToken: "token", refreshToken: "refresh")
                    subject.oauth(event: OAuth2Event.Session(session))
                }
                
                it("should notify the completion closure") {
                    expect(completionSession) == session
                }
            }
        }
        
        describe("webView:webView:shouldStartLoadingWithRequest") {
        
            beforeEach {
                try! subject.start()
            }
            
            context("when the provider returns a request") {
                it("should return true") {
                    let shouldRedirect = subject.webView(webview, shouldStartLoadWithRequest: NSURLRequest(URL: NSURL(string: "test://request")!), navigationType: UIWebViewNavigationType.Other)
                    expect(shouldRedirect) == false
                }
            }
            
            context("when the provider doesn't return a request") {
                it("should return true") {
                    let shouldRedirect = subject.webView(webview, shouldStartLoadWithRequest: NSURLRequest(URL: NSURL(string: "test://test")!), navigationType: UIWebViewNavigationType.Other)
                    expect(shouldRedirect) == true
                }
            }
            
        }
        
    }
}

// MARK: - Mocks

private struct MockProvider: OAuth2Provider {
    
    var authorization: Authorization = { () -> NSURL in
        return NSURL(string: "test://test")!
    }
    
    var authentication: Authentication = { url -> NSURLRequest? in
        if url.absoluteString.containsString("request") {
            return NSURLRequest(URL: url)
        }
        return nil
    }
    
    var sessionAdapter: SessionAdapter = { (data, response) -> OAuth2Session? in
        return nil
    }
    
}

private class MockWebView: UIWebView {
    
    var requestLoaded: NSURLRequest!
    
    override func loadRequest(request: NSURLRequest) {
        self.requestLoaded = request
    }
    
}