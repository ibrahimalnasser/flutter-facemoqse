class Event {
  String eventId;
  String eventName;
  String eventDate;
  String eventTime;
  String eventDuration;
  String participantName;
  String participantEmail;
  String eventFrequency;
  String eventType;
  String eventFrequencyDay;
  String eventFrequencyWeek;
  String eventFrequencyMonth;
  String eventFrequencyYear;
  String eventFrequencyEndDate;
  String eventFrequencyOccurrences;
  String accepted;
  String? code;
  String eventDesc;
  EventRoom eventRoom;

  Event({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.eventDuration,
    required this.participantName,
    required this.participantEmail,
    required this.eventFrequency,
    required this.eventType,
    required this.eventFrequencyDay,
    required this.eventFrequencyWeek,
    required this.eventFrequencyMonth,
    required this.eventFrequencyYear,
    required this.eventFrequencyEndDate,
    required this.eventFrequencyOccurrences,
    required this.accepted,
    this.code,
    required this.eventDesc,
    required this.eventRoom,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'] ?? '',
      eventName: json['eventName'] ?? '',
      eventDate: json['eventDate'] ?? '',
      eventTime: json['eventTime'] ?? '',
      eventDuration: json['eventDuration'] ?? '',
      participantName: json['participantName'] ?? '',
      participantEmail: json['participantEmail'] ?? '',
      eventFrequency: json['eventFrequency'] ?? '',
      eventType: json['eventType'] ?? '',
      eventFrequencyDay: json['eventFrequencyDay'] ?? '',
      eventFrequencyWeek: json['eventFrequencyWeek'] ?? '',
      eventFrequencyMonth: json['eventFrequencyMonth'] ?? '',
      eventFrequencyYear: json['eventFrequencyYear'] ?? '',
      eventFrequencyEndDate: json['eventFrequencyEndDate'] ?? '',
      eventFrequencyOccurrences: json['eventFrequencyOccurrences'] ?? '',
      accepted: json['accepted'] ?? '',
      code: json['code'],
      eventDesc: json['eventDesc'] ?? '',
      eventRoom: EventRoom.fromJson(json['eventRoom'] ?? {}),
    );
  }
}

class EventRoom {
  String roomName;
  String height;
  String width;
  String length;
  String? api;
  String? deviceId;

  EventRoom({
    required this.roomName,
    required this.height,
    required this.width,
    required this.length,
    this.api,
    this.deviceId,
  });

  factory EventRoom.fromJson(Map<String, dynamic> json) {
    return EventRoom(
      roomName: json['RoomName'] ?? '',
      height: json['height'] ?? '',
      width: json['width'] ?? '',
      length: json['length'] ?? '',
      api: json['api'],
      deviceId: json['deviceId'],
    );
  }
}
