//
//  AppEventType.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 18/10/22.
//

import Foundation

enum AppEventType: String {
    case MettingSessionRequestEnd
    
    func payload<T: Encodable>(args: T?) throws -> String {
        let req = AppEventReq(name: self.rawValue, args: args)
        return try req.toJSON() as String
    }
}


fileprivate struct AppEventReq<T: Encodable>: Encodable {
    var name: String
    var arguments: T?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case arguments = "Arguments"
    }
    
    init(name: String, args: T?) {
        self.name = name
        self.arguments = args
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(arguments, forKey: .arguments)
    }
}
