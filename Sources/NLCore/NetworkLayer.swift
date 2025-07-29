import Foundation

public protocol NetworkLayerProtocol {
    func execute(request: URLRequest) async throws -> NetworkResponse
}

public final class NetworkLayer: NetworkLayerProtocol {
    private let networkLayerCore: NetworkLayerCoreProtocol
    public init(session: NetworkLayerSession = URLSession.shared) {
        self.networkLayerCore = NetworkLayerCore(session: session)
    }

    public func execute(request: URLRequest) async throws -> NetworkResponse {
        return try await networkLayerCore.execute(request: request)
    }
}
