import Foundation

public protocol NetworkLayerProtocol {
    func execute<T: Decodable>(request: URLRequest)  async throws -> T
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
    
    public func execute<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, _) = try await networkLayerCore.execute(request: request)
        do {
            return try decoder.attemptToDecode(type: T.self, from: data)
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
