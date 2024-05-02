import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  String matchId;
  List<String> participants;
  String winner;
  String eventId;
  String? graphicLink;
  String? matchTitle;

  Match({
    required this.matchId,
    required this.participants,
    required this.winner,
    required this.eventId,
    required this.graphicLink,
    this.matchTitle,
  });

  factory Match.fromSnapshot(DocumentSnapshot snapshot) {
    final newMatch = Match.fromJson(snapshot.data() as Map<String, dynamic>);
    newMatch.matchId = snapshot.reference.id;
    return newMatch;
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['matchId'],
      participants: List<String>.from(json['participants']),
      winner: json['winner'],
      eventId: json['eventId'],
      graphicLink: json['graphicLink'],
      matchTitle: json['matchTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'participants': participants,
      'winner': winner,
      'eventId': eventId,
      'graphicLink': graphicLink,
      'matchTitle': matchTitle,
    };
  }

  String getMatchTitle() {
    return matchTitle ?? participants.join(' vs. ');
  }
}

var matchImagePlaceHolder =
    'https://firebasestorage.googleapis.com/v0/b/wrestle-predict.appspot.com/o/placeholder.png?alt=media&token=7b29bc6c-cc23-492d-b462-61e4ae22e6b8';
