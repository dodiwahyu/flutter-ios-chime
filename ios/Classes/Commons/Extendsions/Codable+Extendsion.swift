//
//  Codable+Extendsion.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import Foundation

extension KeyedDecodingContainer {
    subscript<T: Decodable>(key: KeyedDecodingContainer.Key) -> T? {
        return try? decodeIfPresent(T.self, forKey: key)
    }
}

extension Encodable {
    /// Converting object to postable JSON
    func toJSON(_ encoder: JSONEncoder = JSONEncoder()) throws -> NSString {
        let data = try encoder.encode(self)
        let result = String(decoding: data, as: UTF8.self)
        return NSString(string: result)
    }
}
