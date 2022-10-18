//
//  String+Extendsion.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import Foundation


extension String {
    func toObject<T: Decodable>(_ type: T.Type) -> T? {
        do {
            if let d = data(using: .utf8) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
            
                let object = try decoder.decode(type, from: d)
                return object
            } else {
                return nil
            }
            
        } catch {
            return nil
        }
    }

}
