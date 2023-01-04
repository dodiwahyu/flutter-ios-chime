class MeetingSessionEntity {
  MeetingSessionEntity({
    this.uuid,
    this.spajNumber,
    this.recordUrl,
    this.recordDate,
    this.wordingText,
    this.meeting,
    this.attendee,
    this.agentJoin,
    this.clientJoin,
    this.asAgent,
  });

  final String? uuid;
  final String? spajNumber;
  final String? recordUrl;
  final String? recordDate;
  final String? wordingText;
  final MeetingEntity? meeting;
  final AttendeeEntity? attendee;
  final bool? agentJoin;
  final bool? clientJoin;
  final bool? asAgent;

  factory MeetingSessionEntity.formJson(Map<String, dynamic> json) =>
      MeetingSessionEntity(
        uuid: json["uuid"],
        spajNumber: json["spajNumber"],
        recordUrl: json["recordUrl"],
        recordDate: json["recordDate"],
        wordingText: json["wordingText"],
        meeting: json["meeting"] == null
            ? null
            : MeetingEntity.fromJson(json["meeting"]),
        attendee: json["attendee"] == null
            ? null
            : AttendeeEntity.fromJson(json["attendee"]),
        agentJoin: json["agentJoin"],
        clientJoin: json["clientJoin"],
        asAgent: json["asAgent"],
      );
}

class MeetingEntity {
  MeetingEntity({
    this.meetingId,
    this.externalMeetingId,
    this.mediaPlacement,
    this.mediaRegion,
  });

  final String? meetingId;
  final String? externalMeetingId;
  final MediaPlacementEntity? mediaPlacement;
  final String? mediaRegion;

  factory MeetingEntity.fromJson(Map<String, dynamic> json) => MeetingEntity(
        meetingId: json["meetingId"],
        externalMeetingId: json["externalMeetingId"],
        mediaPlacement: json["mediaPlacement"] == null
            ? null
            : MediaPlacementEntity.fromJson(json["mediaPlacement"]),
        mediaRegion: json["mediaRegion"],
      );
}

class MediaPlacementEntity {
  MediaPlacementEntity({
    this.audioHostUrl,
    this.audioFallbackUrl,
    this.screenDataUrl,
    this.screenSharingUrl,
    this.screenViewingUrl,
    this.signalingUrl,
    this.turnControlUrl,
    this.eventIngestionUrl,
  });

  final String? audioHostUrl;
  final String? audioFallbackUrl;
  final String? screenDataUrl;
  final String? screenSharingUrl;
  final String? screenViewingUrl;
  final String? signalingUrl;
  final String? turnControlUrl;
  final String? eventIngestionUrl;

  factory MediaPlacementEntity.fromJson(Map<String, dynamic> json) =>
      MediaPlacementEntity(
        audioHostUrl: json["audioHostUrl"],
        audioFallbackUrl: json["audioFallbackUrl"],
        screenDataUrl: json["screenDataUrl"],
        screenSharingUrl: json["screenSharingUrl"],
        screenViewingUrl: json["screenViewingUrl"],
        signalingUrl: json["signalingUrl"],
        turnControlUrl: json["turnControlUrl"],
        eventIngestionUrl: json["eventIngestionUrl"],
      );
}

class AttendeeEntity {
  AttendeeEntity({
    this.attendeeId,
    this.externalUserId,
    this.joinToken,
  });

  final String? attendeeId;
  final String? externalUserId;
  final String? joinToken;

  factory AttendeeEntity.fromJson(Map<String, dynamic> json) => AttendeeEntity(
        attendeeId: json["attendeeId"],
        externalUserId: json["externalUserId"],
        joinToken: json["joinToken"],
      );
}
