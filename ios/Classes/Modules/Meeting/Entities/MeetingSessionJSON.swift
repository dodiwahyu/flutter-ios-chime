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
    
    func convert(isAgent: Bool = false) -> MeetingSessionEntity {
        let meetingEntity = MeetingEntity(
            meetingId: uuid,
            externalMeetingId: spajNo,
            mediaPlacement: meetingJson?.mediaPlacement.convert(),
            mediaRegion: meetingJson?.mediaRegion
        )
        
        let attendee = isAgent ? attendee1 : attendee2
        let attendeEntity = AttendeeEntity(externalUserId: attendee?.externalUserID ?? "", attendeeId: attendee?.attendeeID ?? "", joinToken: attendee?.joinToken ?? "")
        
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
    let externalUserID, attendeeID, joinToken: String
    
    enum CodingKeys: String, CodingKey {
        case externalUserID = "externalUserId"
        case attendeeID = "attendeeId"
        case joinToken
    }
}

// MARK: - MeetingJSON
struct MeetingJSON: Codable {
    let meetingID, externalMeetingID: String
    let mediaPlacement: MediaPlacementJSON
    let mediaRegion: String
    
    enum CodingKeys: String, CodingKey {
        case meetingID = "meetingId"
        case externalMeetingID = "externalMeetingId"
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
    
    func convert() -> MediaPlacementEntity {
        return MediaPlacementEntity(audioHostUrl: audioHostURL, audioFallbackUrl: audioFallbackURL, screenDataUrl: screenDataURL, screenSharingUrl: screenSharingURL, screenViewingUrl: screenViewingURL, signalingUrl: signalingURL, turnControlUrl: turnControlURL, eventIngestionUrl: eventIngestionURL)
    }
}

