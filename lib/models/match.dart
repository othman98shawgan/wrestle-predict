class Match {
  String matchId;
  List<String> participants;
  String winner;
  String eventId;
  String graphicLink;

  Match({
    required this.matchId,
    required this.participants,
    required this.winner,
    required this.eventId,
    required this.graphicLink,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['matchId'],
      participants: List<String>.from(json['participants']),
      winner: json['winner'],
      eventId: json['eventId'],
      graphicLink: json['graphicLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'participants': participants,
      'winner': winner,
      'eventId': eventId,
      'graphicLink': graphicLink,
    };
  }
}
