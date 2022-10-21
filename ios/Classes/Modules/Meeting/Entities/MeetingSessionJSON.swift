import Foundation

// MARK: - VideoConferenceJSON
struct VideoConferenceJSON: Codable {
    let uuid, spajNumber, product, namePh: String
    let emailPh, phoneNumberPh, insuredName, insuredEmail: String
    let insuredPhoneNumber: String
    let meetingJSON: MeetingJSON
    let attendee1, attendee2: AttendeeJSON

    enum CodingKeys: String, CodingKey {
        case uuid, spajNumber, product
        case namePh = "name_ph"
        case emailPh = "email_ph"
        case phoneNumberPh = "phone_number_ph"
        case insuredName = "insured_name"
        case insuredEmail = "insured_email"
        case insuredPhoneNumber = "insured_phone_number"
        case meetingJSON = "meetingJson"
        case attendee1, attendee2
    }
    
    func convert(isAgent: Bool = false) -> MeetingSessionEntity {
        let meetingEntity = MeetingEntity(
            meetingId: meetingJSON.meetingID,
            externalMeetingId: meetingJSON.externalMeetingID,
            mediaPlacement: meetingJSON.mediaPlacement.convert(),
            mediaRegion: meetingJSON.mediaRegion
        )
        
        let attendee = isAgent ? attendee1 : attendee2
        let attendeEntity = AttendeeEntity(externalUserId: attendee.externalUserID, attendeeId: attendee.attendeeID, joinToken: attendee.joinToken)
        
        return MeetingSessionEntity(uuid: uuid, meeting: meetingEntity, attendee: attendeEntity, asAgent: isAgent)
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

