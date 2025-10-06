//
//  Validation.swift
//  
//
//  Created by NY iOS on 25/02/24.
//

import Foundation


public struct Validation {
    public static func validate<T: Codable>(response: HTTPClientResponse) throws -> T {
        switch response.statusCode {
        case 200...299:
            if let data = response.data {
                return try Mapper.map(data)
            }
            throw HTTPClientError.emptySuccess
            
        case 400, 422:
            if let data = response.data {
                let model: ErrorResponseDTO = try Mapper.map(data)
                
                throw HTTPClientError.badRequest(model)
            }
            throw HTTPClientError.badRequest(nil)
            
        case 401:
            throw HTTPClientError.unauthorized
            
        case 403, 409:
            if let data = response.data {
                let model: ErrorResponseDTO = try Mapper.map(data)
                
                throw HTTPClientError.badRequest(model)
            } else {
                throw HTTPClientError.accessDenied
            }
        case 404:
            if let data = response.data {
                let model: ErrorResponseDTO = try Mapper.map(data)
                
                throw HTTPClientError.notFound(model.message)
            }
            
            throw HTTPClientError.notFound("Not found")
            
        case 500...599:
            if let data = response.data {
                let model: ErrorResponseDTO = try Mapper.map(data)
                
                throw HTTPClientError.serviceUnavailable(model.message)
            }
            
            throw HTTPClientError.serviceUnavailable("Server error")
            
        default:
            throw HTTPClientError.responseValidationFailed
        }
    }
}
