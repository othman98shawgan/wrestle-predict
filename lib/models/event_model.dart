class Event {
  final String eventId;
  final String eventName;
  final List<String> matches;
  final String seasonId;
  final String graphicLink;

  Event({
    required this.eventId,
    required this.eventName,
    required this.matches,
    required this.seasonId,
    required this.graphicLink,
  });

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
