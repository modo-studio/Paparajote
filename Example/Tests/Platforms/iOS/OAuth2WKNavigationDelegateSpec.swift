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
        var completionError: Error!
        
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
                expect(webView.loadedRequest.url) == URL(string: "test://test")!
            }
            
            it("should throw an error if start is called once the flow has been started") {
                expect {
                    try subject.start()
                }.to(throwError())
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

private class MockWebView: WKWebView {
    
    fileprivate var loadedRequest: URLRequest!
    
    fileprivate override func load(_ request: URLRequest) -> WKNavigation? {
        self.loadedRequest = request
        return nil
    }
    
}
