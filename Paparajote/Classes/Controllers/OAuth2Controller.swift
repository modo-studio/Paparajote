import Foundation

open class OAuth2Controller {

    // MARK: - Attributes

    internal weak var delegate: OAuth2Delegate?
    internal let provider: OAuth2Provider
    internal let service: Service
    internal var inProgress: Bool = false

    // MARK: - Init

    public convenience init(provider: OAuth2Provider, delegate: OAuth2Delegate) {
        self.init(provider: provider, delegate: delegate, service: Service())
    }

    internal init(provider: OAuth2Provider, delegate: OAuth2Delegate, service: Service) {
        self.provider = provider
        self.delegate = delegate
        self.service = service
    }

    // MARK: - Pubic

    open func start() throws {
        if self.inProgress {
            throw OAuth2Error.alreadyStarted
        }
        self.inProgress = true
        self.delegate?.oauth(event: .open(url: self.provider.authorization()))
    }

    open func shouldRedirect(url: URL) -> Bool {
        guard let request = self.provider.authentication(url) else { return true }
        self.authenticate(request: request)
        return false
    }

    // MARK: - Private

    fileprivate func authenticate(request: URLRequest) {
        self.service.execute(request) { [weak self] (data, response, error) in
            if let data = data, let response = response {
                if let session = self?.provider.sessionAdapter(data, response) {
                    self?.delegate?.oauth(event: .session(session))
                } else {
                    self?.delegate?.oauth(event: .error(OAuth2Error.sessionNotFound))
                }
            } else if let error = error {
                self?.delegate?.oauth(event: .error(error))
            } else {
                self?.delegate?.oauth(event: .error(OAuth2Error.noResponse))
            }
            self?.inProgress = false
        }
    }

}
