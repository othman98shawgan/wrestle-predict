import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String eventId;
  String eventName;
  List<String> matches;
  String seasonId;
  String graphicLink;
  final Map<String, int> leaderboard; //<userId, points>
  final Map<String, Map<String, dynamic>> userPicks; //<userId, <matchId, winner>>

  Event({
    required this.eventId,
    required this.eventName,
    required this.matches,
    required this.seasonId,
    required this.graphicLink,
    required this.leaderboard,
    required this.userPicks,
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
      leaderboard: Map<String, int>.from(json['leaderboard']),
      userPicks: Map<String, Map<String, dynamic>>.from(json['userPicks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'matches': matches,
      'seasonId': seasonId,
      'graphicLink': graphicLink,
      'leaderboard': leaderboard,
      'userPicks': userPicks,
    };
  }
}

var eventImagePlaceHolder =
    'https://firebasestorage.googleapis.com/v0/b/wrestle-predict.appspot.com/o/placeholder.png?alt=media&token=7b29bc6c-cc23-492d-b462-61e4ae22e6b8';
