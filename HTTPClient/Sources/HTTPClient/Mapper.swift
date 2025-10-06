//
//  Mapper.swift
//  
//
//  Created by NY iOS on 07/09/23.
//

import Foundation

open class Mapper {
    public static func map<T: Decodable>(_ data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let model = try decoder.decode(T.self, from: data)
            
            return model
        } catch {
            print("typeMismatch", error)
            throw HTTPClientError.responseSerializationFailed
        }
    }
}
