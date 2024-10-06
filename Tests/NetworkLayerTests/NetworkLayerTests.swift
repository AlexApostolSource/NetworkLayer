import XCTest
@testable import NetworkLayer

final class NetworkLayerTests: XCTestCase {
    
    func test_endpoint() {
        let mockEndpoint = MockEndpoint()
        XCTAssertNotNil(mockEndpoint.asURLRequest)
    }
    
    func testEndpointQueryParams() throws {
        // Given
        let mockEndpoint = MockEndpoint()
        let item = URLQueryItem(name: "test", value: "testValue")
        mockEndpoint.mockURLQueryItems = [item]
        let url = try XCTUnwrap(mockEndpoint.asURLRequest?.url)
        
        // When
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        
        // Then
        XCTAssertEqual(queryItems, mockEndpoint.mockURLQueryItems)
    }
    
    func test_EndpointMethod() throws {
        // Given
        let mockEndpoint = MockEndpoint()
        mockEndpoint.mockRequestMethodValue = .post
        let urlRequest = try XCTUnwrap(mockEndpoint.asURLRequest)
        
        // Then
        XCTAssertEqual(urlRequest.httpMethod, mockEndpoint.method.rawValue)
    }
    
    func test_config() throws {
        let host = "www.testBasePath.com"
        NetworkLayerConfig.config(host: host)
        let endpoint = MockEndpoint()
        let url = try XCTUnwrap(endpoint.asURLRequest?.url)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.host
        XCTAssertEqual(queryItems, host)
    }
}

class MockEndpoint: NetworkLayerEndpoint {
    
    var mockURLQueryItems: [URLQueryItem] = []
    var mockRequestMethodValue: URLRequestMethod = .get
    
    var queryItems: [URLQueryItem] {
        mockURLQueryItems
    }
    
    var path: String {
       "/food/barcode/find-by-id/"
    }
    
    var method: URLRequestMethod {
        mockRequestMethodValue
    }
}
