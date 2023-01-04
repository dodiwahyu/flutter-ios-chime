//
//  AppEventType.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 18/10/22.
//

import Foundation


/**
 All events should be registered in this enum.
 If need add some listener from native to dart please update this section
 */
enum AppEventType: String, Codable {
    case JoinRoomByAgent
    case MeetingSessionRequestEnd
    case ReqRecordMeetingAttendee
    case ReqRecordMeetingAll
    case StopRecordMeeting
    
    /**
     Generate parameter JSON String
     - Parameter args: Object `Encodable` to be encoded as JSON String
     - Returns: a `String` as JSON String
     */
    func payload<T: Encodable>(args: T?) throws -> String {
        let req = AppEventReq(name: self, args: args)
        return try req.toJSON() as String
    }
}


/**
 `AppEventReq` is a model `Encodable` type .
 where `T` is parameters  `Encodable` to be encoded as `JSON` string
 ```
 // Name: Value from `AppEventType`
 // Arguments: String JSON to be parsed to dart function
 {
    "Name": `String`,
    "Arguments": `String`
 }
 ```
 */
fileprivate struct AppEventReq<T: Encodable>: Encodable {
    var name: AppEventType
    var arguments: T?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case arguments = "Arguments"
    }
    
    init(name: AppEventType, args: T?) {
        self.name = name
        self.arguments = args
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(arguments, forKey: .arguments)
    }
}
