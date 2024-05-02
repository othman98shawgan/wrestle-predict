import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String eventId;
  String eventName;
  List<String> matches;
  String seasonId;
  String graphicLink;

  Event({
    required this.eventId,
    required this.eventName,
    required this.matches,
    required this.seasonId,
    required this.graphicLink,
  });

  factory Event.fromSnapshot(DocumentSnapshot snapshot) {
    final newEvent = Event.fromJson(snapshot.data() as Map<String, dynamic>);
    newEvent.eventId = snapshot.reference.id;
    return newEvent;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'],
      eventName: json['eventName'],
      matches: List<String>.from(json['matches']),
      seasonId: json['seasonId'],
      graphicLink: json['graphicLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'matches': matches,
      'seasonId': seasonId,
      'graphicLink': graphicLink,
    };
  }
}
