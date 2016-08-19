import Foundation
import Quick
import Nimble

@testable import Paparajote

class OAuth2ErrorSpec: QuickSpec {
    override func spec() {
        describe("-description") {
            it("should return the correct description for .AlreadyStarted") {
                expect(OAuth2Error.AlreadyStarted.description) == "Oauth2 flow already started."
            }
            
            it("should return the correct description for .NoResponse") {
                expect(OAuth2Error.NoResponse.description) == "No response from the provider."
            }
            
            it("should return the correct description for .SessionNotFound") {
                expect(OAuth2Error.SessionNotFound.description) == "Session not found"
            }
        }
    }
}