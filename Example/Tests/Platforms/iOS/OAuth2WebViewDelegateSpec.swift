import Foundation
import Quick
import Nimble

@testable import Paparajote

class OAuth2WebViewDelegateSpec: QuickSpec {
    override func spec() {
        
        var subject: OAuth2WebViewDelegate!
        var provider: MockProvider!
        var webview: MockWebView!
        var completionError: Error!
        var completionSession: OAuth2Session!
        
        beforeEach {
            provider = MockProvider()
            webview = MockWebView()
            subject = OAuth2WebViewDelegate(provider: provider, webView: webview, completion: { (session, error) in
                completionError = error
                completionSession = session
            })
        }
        
        describe("-start") {
            
            beforeEach {
                try! subject.start()
            }
            
            it("should load the authorization request in the webview") {
                expect(webview.requestLoaded.url) == URL(string: "test://test")!
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
                    error = OAuth2Error.alreadyStarted
                    subject.oauth(event: OAuth2Event.error(error))
                }
                
                it("should send the error to the completion closure") {
                    expect(error) == completionError as? OAuth2Error
                }
            }
            
            context("when a session is sent") {
                var session: OAuth2Session!
                beforeEach {
                    session = OAuth2Session(accessToken: "token", refreshToken: "refresh")
                    subject.oauth(event: OAuth2Event.session(session))
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
                    let shouldRedirect = subject.webView(webView: webview, shouldStartLoadWithRequest: URLRequest(url: URL(string: "test://request")!) as NSURLRequest, navigationType: .other)
                    expect(shouldRedirect) == false
                }
            }
            
            context("when the provider doesn't return a request") {
                it("should return true") {
                    let shouldRedirect = subject.webView(webView: webview, shouldStartLoadWithRequest: URLRequest(url: URL(string: "test://test")!) as NSURLRequest, navigationType: .other)
                    expect(shouldRedirect) == true
                }
            }
            
        }
        
    }
}

// MARK: - Mocks

private struct MockProvider: OAuth2Provider {
    
    var authorization: Authorization = { () -> URL in
        return URL(string: "test://test")!
    }
    
    var authentication: Authentication = { url -> URLRequest? in
        if url.absoluteString.contains("request") {
            return URLRequest(url: url)
        }
        return nil
    }
    
    var sessionAdapter: SessionAdapter = { (data, response) -> OAuth2Session? in
        return nil
    }
    
}

private class MockWebView: UIWebView {
    
    var requestLoaded: URLRequest!
    
    override func loadRequest(_ request: URLRequest) {
        self.requestLoaded = request
    }
    
}
