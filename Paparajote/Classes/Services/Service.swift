import Foundation

internal class Service {

    // MARK: - Attributes

    private let session: NSURLSession

    // MARK: - Init

    internal init(session: NSURLSession = NSURLSession.sharedSession()) {
        self.session = session
    }

    // MARK: - Internal

    internal func execute(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        self.session
            .dataTaskWithRequest(request, completionHandler: completionHandler)
            .resume()
    }

}
