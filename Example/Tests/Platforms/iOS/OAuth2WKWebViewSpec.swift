import Foundation
import Quick
import Nimble
import WebKit

@testable import Paparajote

class OAuth2WKWebViewSpec: QuickSpec {
    override func spec() {
        
        var subject: MockOAuth2WKWebView!
        var provider: MockProvider!
        var completion: OAuth2SessionCompletion!
        
        beforeEach {
            provider = MockProvider()
            completion = { (_, _) in }
            subject = try! MockOAuth2WKWebView(frame: CGRectZero, provider: provider, completion: completion)
        }
        
        describe("-init:frame:provider:completion:") {
            
            it("should have a delegate with the correct webview") {
                expect(subject.oauthDelegate.webView as! OAuth2WKWebView).to(beIdenticalTo(subject))
            }
            
            it("should call start") {
                expect(subject.requestLoaded) == true
            }
            
        }
        
    }
}


// MARK: - Mocks

private class MockOAuth2WKWebView: OAuth2WKWebView {
    
    var requestLoaded: Bool = false
    
    func loadRequest(request: NSURLRequest) {
        self.requestLoaded = true
    }
    
}

private class MockProvider: OAuth2Provider {
    
    var started: Bool = false
    
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