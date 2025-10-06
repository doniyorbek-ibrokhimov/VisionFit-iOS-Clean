//
//  AlamofireClient.swift
//
//
//  Created by NY on 13/09/22.
//

import Foundation
import Alamofire

public class AlamofireClient: HTTPClient {

    private let sessionConfiguration: URLSessionConfiguration

    public init(_ sessionConfiguration: URLSessionConfiguration = .default) {
        self.sessionConfiguration = sessionConfiguration
    }

    private struct UnexpectedValuesRepresentation: Error {}
    
    private struct DownloadTaskWrapper: HTTPClientTask {
        let wrapped: DownloadRequest
        
        func cancel() {
            wrapped.cancel()
        }
    }

    private struct TaskWrapper: HTTPClientTask {
        let wrapped: DataRequest

        func cancel() {
            wrapped.cancel()
        }
    }

    public func task(_ url: URL, method: HTTPMethod, parameters: [String : Any], encoding: HTTPEncoding, headers: [String : String], completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {

        let request = AF.request(url,
                   method: method.afMethod,
                   parameters: parameters,
                   encoding: encoding.afParameterEncoding,
                   headers: HTTPHeaders(headers))
            .response { afResponse in
                
                guard let response = afResponse.response, let data = afResponse.data else {
                    completion(.failure(afResponse.error ?? UnexpectedValuesRepresentation()))
                    return
                }
                LogManager.log(data: afResponse.data, response: response, request: afResponse.request)
                completion(.success((data, response)))
            }

        return TaskWrapper(wrapped: request)
    }
    
    public func task(_ url: URL, method: HTTPMethod = .get, parameters: [String : Any] = [:], encoding: HTTPEncoding = .url, headers: [String : String] = [:]) async throws -> HTTPClientResponse {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                            method: method.afMethod,
                            parameters: parameters,
                            encoding: encoding.afParameterEncoding,
                            headers: HTTPHeaders(headers))
            .response { afResponse in
                guard let response = afResponse.response else {
                    
                    if let error = afResponse.error {
                        continuation.resume(throwing: error.httpClientError)
                    } else {
                        continuation.resume(throwing: HTTPClientError.unknown)
                    }
                    return
                }
                
//                print("HTTP request time: ", afResponse.timeline.totalDuration)
                LogManager.log(data: afResponse.data, response: response, request: afResponse.request)
                
                continuation.resume(returning: HTTPClientResponse(request: afResponse.request, response: afResponse.response, data: afResponse.data))
            }
        }
    }

    public func upload(to url: URL, files: [(param: String, file: Data, fileName: String, mimeType: String)], parameters: [String : String], encoding: HTTPEncoding, headers: [String : String], completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {

        let multiData = MultipartFormData()
        files.forEach({multiData.append($0.file, withName: $0.param, fileName: $0.fileName, mimeType: $0.mimeType)})
        
        parameters.forEach { (key: String, value: String) in
            if let data = value.data(using: .utf8) {
                multiData.append(data, withName: key)
            }
        }
                
        let request = AF.upload(multipartFormData: multiData, to: url, headers: HTTPHeaders(headers))
            .response { afResponse in
                
                guard let response = afResponse.response, let data = afResponse.data else {
                    completion(.failure(afResponse.error ?? UnexpectedValuesRepresentation()))
                    return
                }
                LogManager.log(data: afResponse.data, response: response, request: afResponse.request)

                completion(.success((data, response)))
            }

        return TaskWrapper(wrapped: request)
    }
    
    public func download(from url: URL, method: HTTPMethod, parameters: [String : Any], encoding: HTTPEncoding, headers: [String : String], completion: @escaping (Result<(Data?, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        
        let request = AF.download(
            url,
            method: method.afMethod,
            parameters: parameters,
            encoding: encoding.afParameterEncoding,
            headers: HTTPHeaders(headers)).downloadProgress(closure: { (progress) in
                //progress closure
            }).responseData { response in
                guard response.error == nil,
                   let url = response.fileURL,
                   let data = try? Data(contentsOf: url),
                   let response = response.response else {
                    completion(.failure(response.error!))
                    return
                }
                completion(.success((data, response)))
            }
        
        return DownloadTaskWrapper(wrapped: request)
    }
    
    public func download(from url: URL, method: HTTPMethod, parameters: [String : Any], encoding: HTTPEncoding, headers: [String : String]) async throws -> HTTPClientResponse {
        try await withCheckedThrowingContinuation { continuation in
            AF.download(
                url,
                method: method.afMethod,
                parameters: parameters,
                encoding: encoding.afParameterEncoding,
                headers: HTTPHeaders(headers)).downloadProgress(closure: { (progress) in
                    //progress closure
                }).responseData { response in
                    
                    if let url = response.fileURL, let data = try? Data(contentsOf: url) {
                        continuation.resume(returning: HTTPClientResponse(request: response.request, response: response.response, data: data))
                    } else if let error = response.error {
                        continuation.resume(throwing: error.httpClientError)
                    } else {
                        continuation.resume(throwing: HTTPClientError.notFound(nil))
                    }
                }
        }
    }
}

extension AFError {
    var httpClientError: HTTPClientError {
        switch self {
        case .invalidURL:
            return HTTPClientError.invalidURL
        case .parameterEncodingFailed:
            return HTTPClientError.parameterEncodingFailed
        case .multipartEncodingFailed:
            return HTTPClientError.multipartEncodingFailed
        case .responseValidationFailed:
            return HTTPClientError.responseValidationFailed
        case .responseSerializationFailed:
            return HTTPClientError.responseSerializationFailed
        default:
            return HTTPClientError.unknown
        }
    }
}

private extension HTTPMethod {
    var afMethod: Alamofire.HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .patch: return .patch
        case .put: return .put
        case .delete: return .delete
        }
    }
}

private extension HTTPEncoding {
    var afParameterEncoding: ParameterEncoding {
        switch self {
        case .json:
            return JSONEncoding.prettyPrinted
        case .body:
            return URLEncoding.httpBody
        case .url:
            return URLEncoding.queryString
        }
    }
}
