//
//  ErrorResponseDTO.swift
//
//
//  Created by NY iOS on 25/02/24.
//


import Foundation

public struct ErrorResponseDTO: Codable {
    public let message: String?
    
    public let statusCode: Int?
    
    public let errors: [ErrorDetailsDTO]
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        message = try? container?.decodeIfPresent(String.self, forKey: .message)
        statusCode = try? container?.decodeIfPresent(Int.self, forKey: .statusCode)
        errors = (try? container?.decode([ErrorDetailsDTO].self, forKey: .errors)) ?? []
    }
    
    enum CodingKeys: CodingKey {
        case message, errors, statusCode
    }
}

public struct ErrorDetailsDTO: Codable {
    public let msg: String?
    
    public let param: String?
    
    public init(msg: String? = nil, param: String? = nil) {
        self.msg = msg
        self.param = param
    }
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        msg = try? container?.decode(String.self, forKey: .msg)
        param = try? container?.decode(String.self, forKey: .param)
    }
    
    enum CodingKeys: CodingKey {
        case msg, param
    }
}
