import Foundation

public enum HTTPEncoding {
    case json
    case url
    case body
}

public enum HTTPMethod {
    case get
    case post
    case patch
    case put
    case delete
}

public enum HTTPClientError: Error {
    case invalidURL
    case parameterEncodingFailed
    case multipartEncodingFailed
    case responseValidationFailed
    case responseSerializationFailed
    case unauthorized
    case notFound(String?)
    case badRequest(ErrorResponseDTO?)
    case accessDenied
    case blocked
    case emptySuccess
    case urlSession(String)
    case serviceUnavailable(String?)
    case unknown
}


public struct HTTPClientResponse {
    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The data returned by the server.
    public let data: Data?
    
    /// default 0
    public var statusCode: Int {
        response?.statusCode ?? 0
    }
    
    public var isSuccessful: Bool {
        switch statusCode {
        case 200...299:
            return true
            
        default:
            return false
        }
    }
    
    init(request: URLRequest?, response: HTTPURLResponse?, data: Data?) {
        self.request = request
        self.response = response
        self.data = data
    }
}

public protocol HTTPClientTask {
    func cancel()
}


public protocol HTTPClient {
    typealias Result = Swift.Result<(Data?, HTTPURLResponse), Error>
    
    @discardableResult
    func task(_ url: URL, method: HTTPMethod, parameters: [String: Any], encoding: HTTPEncoding, headers: [String: String], completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask
    
    @discardableResult
    func task(_ url: URL, method: HTTPMethod, parameters: [String: Any], encoding: HTTPEncoding, headers: [String: String]) async throws -> HTTPClientResponse
    
    @discardableResult
    func upload(to url: URL, files: [(param: String, file: Data, fileName: String, mimeType: String)], parameters: [String: String], encoding: HTTPEncoding, headers: [String: String], completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask
    
    @discardableResult
    func download(from url: URL, method: HTTPMethod, parameters: [String: Any], encoding: HTTPEncoding, headers: [String: String], completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask
    
    @discardableResult
    func download(from url: URL, method: HTTPMethod, parameters: [String: Any], encoding: HTTPEncoding, headers: [String: String]) async throws -> HTTPClientResponse
}
