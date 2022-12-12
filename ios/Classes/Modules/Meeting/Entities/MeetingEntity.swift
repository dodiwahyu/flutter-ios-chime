//
//  MeetingEntity.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import Foundation


struct MeetingEntity: Codable {
    let meetingId: String?
    let externalMeetingId: String?
    let mediaPlacement: MediaPlacementEntity?
    let mediaRegion: String?
    
    private enum CodingKeys: String, CodingKey {
        case meetingId
        case externalMeetingId
        case mediaPlacement
        case mediaRegion
    }
    
    init(meetingId: String?,
         externalMeetingId: String?,
         mediaPlacement: MediaPlacementEntity?,
         mediaRegion: String?) {
        self.meetingId = meetingId
        self.externalMeetingId = externalMeetingId
        self.mediaPlacement = mediaPlacement
        self.mediaRegion = mediaRegion
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        meetingId = values[.meetingId]
        externalMeetingId = values[.externalMeetingId]
        mediaPlacement = values[.mediaPlacement]
        mediaRegion = values[.mediaRegion]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(meetingId, forKey: .meetingId)
        try container.encodeIfPresent(externalMeetingId, forKey: .externalMeetingId)
        try container.encodeIfPresent(mediaPlacement, forKey: .mediaPlacement)
        try container.encodeIfPresent(mediaRegion, forKey: .mediaRegion)
    }
}
