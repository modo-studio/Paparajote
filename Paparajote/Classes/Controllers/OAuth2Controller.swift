import Foundation

public class OAuth2Controller {

    // MARK: - Attributes

    private weak var delegate: OAuth2Delegate?
    private let provider: OAuth2Provider
    private let service: Service
    private var inProgress: Bool = false

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

    public func start() throws {
        if self.inProgress {
            throw OAuth2Error.AlreadyStarted
        }
        self.inProgress = true
        self.delegate?.oauth(event: .Open(url: self.provider.authorization()))
    }

    public func shouldRedirect(url url: NSURL) -> Bool {
        guard let request = self.provider.authentication(url) else { return true }
        self.authenticate(request: request)
        return true
    }

    // MARK: - Private

    private func authenticate(request request: NSURLRequest) {
        self.service.execute(request) { [weak self] (data, response, error) in
            if let data = data, response = response {
                if let session = self?.provider.sessionAdapter(data, response) {
                    self?.delegate?.oauth(event: .Session(session))
                } else {
                    self?.delegate?.oauth(event: .Error(OAuth2Error.SessionNotFound))
                }
            } else if let error = error {
                self?.delegate?.oauth(event: .Error(error))
            } else {
                self?.delegate?.oauth(event: .Error(OAuth2Error.NoResponse))
            }
            self?.inProgress = false
        }
    }

}
