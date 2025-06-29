import Foundation

public protocol NetworkLayerProtocol {
    func execute(request: URLRequest) async throws -> Result<(Data, URLResponse), Error>
}

public final class NetworkLayer: NetworkLayerProtocol {
    private let networkLayerCore: NetworkLayerCoreProtocol
    private let logger: NetworkLayerLogger?
    private let decoder: NetworkLayerDecoder
    public init(
        urlSession: URLSession = .shared,
        logger: NetworkLayerLogger?,
        decoder: NetworkLayerDecoder = JSONDecoder()
    ) {
        self.logger = logger
        self.networkLayerCore = NetworkLayerCore(session: urlSession, logger: logger)
        self.decoder = decoder
    }

    public func execute(request: URLRequest) async throws -> Result<(Data, URLResponse), Error> {
        return try await networkLayerCore.execute(request: request)
    }
}
