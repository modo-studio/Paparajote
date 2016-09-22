import Foundation

internal class Service {

    // MARK: - Attributes

    private let session: URLSession

    // MARK: - Init

    internal init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    // MARK: - Internal

    internal func execute(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.session
            .dataTask(with: request, completionHandler: completionHandler)
            .resume()
    }

}
