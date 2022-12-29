//
//  MeetingSessionEntity.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import Foundation
import AmazonChimeSDK

struct MeetingSessionEntity: Codable {
    let uuid: String?
    let spajNumber: String?
    let meeting: MeetingEntity?
    let attendee: AttendeeEntity?
    let recordUrl: String?
    let recordDate: String?
    let wordingTextAgent: String?
    let wordingTextClient: String?
    let agentJoin: Bool?
    let clientJoin: Bool?
    let asAgent: Bool?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case spajNumber
        case meeting
        case attendee
        case recordUrl
        case recordDate
        case wordingTextAgent
        case wordingTextClient
        case agentJoin
        case clientJoin
        case asAgent
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = values[.uuid]
        spajNumber = values[.spajNumber]
        meeting = values[.meeting]
        attendee = values[.attendee]
        recordUrl = values[.recordUrl]
        recordDate = values[.recordDate]
        wordingTextAgent = values[.wordingTextAgent]
        wordingTextClient = values[.wordingTextClient]
        agentJoin = values[.agentJoin]
        clientJoin = values[.clientJoin]
        asAgent = values[.asAgent]
    }
    
    func getMeetingResponse() -> CreateMeetingResponse? {
        guard let mediaPlacement = meeting?.mediaPlacement?.mediaPlacement,
              let mediaRegion = meeting?.mediaRegion,
              let meetingId = meeting?.meetingId
        else { return nil }
        let meeting = Meeting(
            externalMeetingId: meeting?.externalMeetingId,
            mediaPlacement: mediaPlacement,
            mediaRegion: mediaRegion,
            meetingId: meetingId
        )
        return CreateMeetingResponse(meeting: meeting)
    }
    
    func getAttendeeResponse() -> CreateAttendeeResponse? {
        guard let id = attendee?.attendeeId,
              let userId = attendee?.externalUserId,
              let token = attendee?.joinToken
        else { return nil }
        
        let entity = Attendee(attendeeId: id, externalUserId: userId, joinToken: token)
        return CreateAttendeeResponse(attendee: entity)
    }
}

