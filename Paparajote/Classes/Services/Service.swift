import Foundation

internal class Service {

    // MARK: - Attributes

    fileprivate let session: URLSession

    // MARK: - Init

    internal init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    // MARK: - Internal

    internal func execute(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, NSError?) -> Void) {
        self.session
            .dataTask(with: request, completionHandler: completionHandler as! (Data?, URLResponse?, Error?) -> Void)
            .resume()
    }

}
