class Event {
  final String eventId;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventDuration;
  final String participantName;
  final String participantEmail;
  final String eventFrequency;
  final String eventType;
  final String eventFrequencyDay;
  final String eventFrequencyWeek;
  final String eventFrequencyMonth;
  final String eventFrequencyYear;
  final String eventFrequencyEndDate;
  final String eventFrequencyOccurrences;
  final String accepted;
  final String code;
  final String eventDesc;
  // Make this field dynamic to handle both string and EventRoom object
  final dynamic eventRoom;

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
    required this.code,
    required this.eventDesc,
    required this.eventRoom,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Handle eventRoom field - check if it's a string or an object
    dynamic eventRoomData = json['eventRoom'];
    dynamic eventRoom;

    if (eventRoomData is String) {
      // If eventRoom is a string, store it directly
      eventRoom = eventRoomData;
    } else if (eventRoomData is Map) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      Map<String, dynamic> convertedMap = {};
      eventRoomData.forEach((key, value) {
        if (key is String) {
          convertedMap[key] = value;
        } else {
          // If the key is not a String, convert it to String
          convertedMap[key.toString()] = value;
        }
      });

      // Now pass the properly typed map to EventRoom.fromJson
      eventRoom = EventRoom.fromJson(convertedMap);
    } else {
      // Default empty value
      eventRoom = '';
    }

    return Event(
      eventId: json['eventId']?.toString() ?? '',
      eventName: json['eventName']?.toString() ?? '',
      eventDate: json['eventDate']?.toString() ?? '',
      eventTime: json['eventTime']?.toString() ?? '',
      eventDuration: json['eventDuration']?.toString() ?? '',
      participantName: json['participantName']?.toString() ?? '',
      participantEmail: json['participantEmail']?.toString() ?? '',
      eventFrequency: json['eventFrequency']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      eventFrequencyDay: json['eventFrequencyDay']?.toString() ?? '',
      eventFrequencyWeek: json['eventFrequencyWeek']?.toString() ?? '',
      eventFrequencyMonth: json['eventFrequencyMonth']?.toString() ?? '',
      eventFrequencyYear: json['eventFrequencyYear']?.toString() ?? '',
      eventFrequencyEndDate: json['eventFrequencyEndDate']?.toString() ?? '',
      eventFrequencyOccurrences:
          json['eventFrequencyOccurrences']?.toString() ?? '',
      accepted: json['accepted']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      eventDesc: json['eventDesc']?.toString() ?? '',
      eventRoom: eventRoom,
    );
  }

  // Get eventRoom name, handling both String and EventRoom object
  String getEventRoomName() {
    if (eventRoom is String) {
      return eventRoom;
    } else if (eventRoom is EventRoom) {
      return eventRoom.name; // Assuming EventRoom has a 'name' property
    }
    return '';
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
