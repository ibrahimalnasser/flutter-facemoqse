import 'dart:convert';

class Data {
  String? Title;
  String? Message;
  String? date;
  String? time;
  String? maxPerson;
  bool? isEvent;
  int? mosqueId;
  int? eventId;

  Data(
    this.Title,
    this.Message,
    this.date,
    this.time,
    this.maxPerson,
    this.isEvent,
    this.mosqueId,
    this.eventId,
  );
  String? get getTitle => Title;

  set setTitle(String? Title) => this.Title = Title;

  get getMessage => Message;

  set setMessage(Message) => this.Message = Message;

  get getDate => date;

  set setDate(date) => this.date = date;

  get getTime => time;

  set setTime(time) => this.time = time;

  get getMaxPerson => maxPerson;

  set setMaxPerson(maxPerson) => this.maxPerson = maxPerson;

  get getIsEvent => isEvent;

  set setIsEvent(isEvent) => this.isEvent = isEvent;

  get getMosqueId => mosqueId;

  set setMosqueId(int mosqueId) => this.mosqueId = mosqueId;

  get getEventId => eventId;

  set setEventId(eventId) => this.eventId = eventId;

  Map<String, dynamic> toMap() {
    return {
      'Title': Title,
      'Message': Message,
      'date': date,
      'time': time,
      'maxPerson': maxPerson,
      'isEvent': isEvent,
      'mosqueid': mosqueId,
      'eventId': eventId,
    };
  }

  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(
      map['Title'],
      map['Message'],
      map['date'],
      map['time'],
      map['maxPerson'],
      map['isEvent'],
      map['mosqueId']?.toInt(),
      map['eventId']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Data.fromJson(String source) => Data.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Data(Title: $Title, Message: $Message, date: $date, time: $time, maxPerson: $maxPerson, isEvent: $isEvent, mosqueId: $mosqueId, eventId: $eventId)';
  }
}
