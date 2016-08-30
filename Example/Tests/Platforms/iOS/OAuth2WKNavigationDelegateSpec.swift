import Foundation
import Quick
import Nimble
import WebKit

@testable import Paparajote

class OAuth2WKNavigationDelegateSpec: QuickSpec {
    override func spec() {
        
        var subject: OAuth2WKNavigationDelegate!
        var provider: MockProvider!
        var webView: MockWebView!
        var completionSession: OAuth2Session!
        var completionError: ErrorType!
        
        beforeEach {
            provider = MockProvider()
            webView = MockWebView()
            subject = OAuth2WKNavigationDelegate(provider: provider, webView: webView, completion: { (session, error) in
                completionSession = session
                completionError = error
            })
        }
        
        describe("-start") {
            beforeEach {
                try! subject.start()
            }
            
            it("should load the correct request in the webview") {
                expect(webView.loadedRequest.URL) == NSURL(string: "test://test")!
            }
            
            it("should throw an error if start is called once the flow has been started") {
                expect {
                    try subject.start()
                }.to(throwError())
            }
        }
        
        describe("-webView:webView:decidePolicyForNavigationAction:decisionHandler") {
            
            var returnedPolicy: WKNavigationActionPolicy!
            
            context("when the navigation action doesn't include URL") {
                
                beforeEach {
                    subject.webView(webView, decidePolicyForNavigationAction: WKNavigationAction(), decisionHandler: { (policy) in
                        returnedPolicy = policy
                    })
                }
                
                it("should allow navigation") {
                    expect(returnedPolicy) == WKNavigationActionPolicy.Allow
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

private class MockWebView: WKWebView {
    
    private var loadedRequest: NSURLRequest!
    
    private override func loadRequest(request: NSURLRequest) -> WKNavigation? {
        self.loadedRequest = request
        return nil
    }
    
}