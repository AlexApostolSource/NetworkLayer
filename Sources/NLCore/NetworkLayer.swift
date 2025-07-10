import Foundation

public protocol NetworkLayerProtocol {
    func execute(request: URLRequest) async throws -> NetworkResponse
}

public final class NetworkLayer: NetworkLayerProtocol {
    private let networkLayerCore: NetworkLayerCoreProtocol
    private let logger: NetworkLayerLogger?
    public init(
        urlSession: URLSession = .shared,
        logger: NetworkLayerLogger?
    ) {
        self.logger = logger
        self.networkLayerCore = NetworkLayerCore(session: urlSession, logger: logger)
    }

    public func execute(request: URLRequest) async throws -> NetworkResponse {
        return try await networkLayerCore.execute(request: request)
    }
}
