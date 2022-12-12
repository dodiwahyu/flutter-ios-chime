import Foundation

// MARK: - VideoConferenceJSON
struct VideoConferenceJSON: Codable {
    let uuid: String?
    let spajNo: String?
    let attendee1: AttendeeJSON?
    let attendee2: AttendeeJSON?
    let meetingJson: MeetingJSON?
    let recordUrl: String?
    let recordDate: String?
    let wordingText: String?
    let agentJoin: Bool?
    let clientJoin: Bool?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case spajNo
        case attendee1
        case attendee2
        case meetingJson
        case recordUrl
        case recordDate
        case wordingText
        case agentJoin
        case clientJoin
    }
    
    func convertToEntity(isAgent: Bool = true) -> MeetingSessionEntity {
        let meetingEntity = MeetingEntity(
            meetingId: uuid,
            externalMeetingId: spajNo,
            mediaPlacement: meetingJson?.mediaPlacement.convert(),
            mediaRegion: meetingJson?.mediaRegion
        )
        
        let attendee = isAgent ? attendee1 : attendee2
        let attendeEntity = AttendeeEntity(externalUserId: attendee?.externalUserId ?? "", attendeeId: attendee?.attendeeId ?? "", joinToken: attendee?.joinToken ?? "")
        
        return MeetingSessionEntity(
            uuid: uuid,
            spajNumber: spajNo,
            meeting: meetingEntity,
            attendee: attendeEntity,
            asAgent: isAgent
        )
    }
}

// MARK: - Attendee
struct AttendeeJSON: Codable {
    let externalUserId, attendeeId, joinToken: String
    
    enum CodingKeys: String, CodingKey {
        case externalUserId
        case attendeeId
        case joinToken
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.externalUserId = try container.decode(String.self, forKey: .externalUserId)
        self.attendeeId = try container.decode(String.self, forKey: .attendeeId)
        self.joinToken = try container.decode(String.self, forKey: .joinToken)
    }
}

// MARK: - MeetingJSON
struct MeetingJSON: Codable {
    let meetingId, externalMeetingId: String
    let mediaPlacement: MediaPlacementJSON
    let mediaRegion: String
    
    enum CodingKeys: String, CodingKey {
        case meetingId
        case externalMeetingId
        case mediaPlacement, mediaRegion
    }
}

// MARK: - MediaPlacement
struct MediaPlacementJSON: Codable {
    let audioHostURL, audioFallbackURL, screenDataURL, screenSharingURL: String
    let screenViewingURL, signalingURL: String
    let turnControlURL, eventIngestionURL: String
    
    enum CodingKeys: String, CodingKey {
        case audioHostURL = "audioHostUrl"
        case audioFallbackURL = "audioFallbackUrl"
        case screenDataURL = "screenDataUrl"
        case screenSharingURL = "screenSharingUrl"
        case screenViewingURL = "screenViewingUrl"
        case signalingURL = "signalingUrl"
        case turnControlURL = "turnControlUrl"
        case eventIngestionURL = "eventIngestionUrl"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.audioHostURL = try container.decode(String.self, forKey: .audioHostURL)
        self.audioFallbackURL = try container.decode(String.self, forKey: .audioFallbackURL)
        self.screenDataURL = try container.decode(String.self, forKey: .screenDataURL)
        self.screenSharingURL = try container.decode(String.self, forKey: .screenSharingURL)
        self.screenViewingURL = try container.decode(String.self, forKey: .screenViewingURL)
        self.signalingURL = try container.decode(String.self, forKey: .signalingURL)
        self.turnControlURL = try container.decode(String.self, forKey: .turnControlURL)
        self.eventIngestionURL = try container.decode(String.self, forKey: .eventIngestionURL)
    }
    
    func convert() -> MediaPlacementEntity {
        return MediaPlacementEntity(audioHostUrl: audioHostURL, audioFallbackUrl: audioFallbackURL, screenDataUrl: screenDataURL, screenSharingUrl: screenSharingURL, screenViewingUrl: screenViewingURL, signalingUrl: signalingURL, turnControlUrl: turnControlURL, eventIngestionUrl: eventIngestionURL)
    }
}

