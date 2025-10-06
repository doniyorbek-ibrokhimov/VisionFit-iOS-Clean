//
//  Encodable+Dictionary.swift
//  
//
//  Created by NY iOS on 25/02/24.
//

import Foundation

public extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}
