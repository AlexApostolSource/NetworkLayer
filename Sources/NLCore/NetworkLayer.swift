import Foundation

public protocol NetworkLayerProtocol {
    func execute<T: Decodable>(request: URLRequest)  async throws -> T
}

public final class NetworkLayer: NetworkLayerProtocol {
   private let networkLayerCore: NetworkLayerCoreProtocol
   private let logger: NetworkLayerLogger?
    
    public init(urlSession: URLSession = .shared, logger: NetworkLayerLogger?) {
        self.logger = logger
        self.networkLayerCore = NetworkLayerCore(session: urlSession, logger: logger)
    }
    
    public func execute<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, _) = try await networkLayerCore.execute(request: request)
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger?.log(
                logMetadata: NetworkLayerLogMetadata(
                    logLevel: .error,
                    subsystem: .decoding(error)
                )
            )
            throw error
        }
    }
}
