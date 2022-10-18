//
//  MeetingSessionEntity.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import Foundation
import AmazonChimeSDK

struct MeetingSessionEntity: Codable {
    let meeting: MeetingEntity?
    let attendee: AttendeeEntity?
    
    func getMeeting() -> CreateMeetingResponse? {
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
    
    func getAttendee() -> CreateAttendeeResponse? {
        guard let id = attendee?.attendeeId,
              let userId = attendee?.externalUserId,
              let token = attendee?.joinToken
        else { return nil }
        
        let entity = Attendee(attendeeId: id, externalUserId: userId, joinToken: token)
        return CreateAttendeeResponse(attendee: entity)
    }
}
