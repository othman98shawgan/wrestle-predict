class Season {
  final String seasonId;
  final String seasonName;
  final List<String> events;
  final Map<String, int> leaderboard;
  final bool isActive;

  Season({
    required this.seasonId,
    required this.seasonName,
    required this.events,
    required this.leaderboard,
    required this.isActive,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonId: json['seasonId'],
      seasonName: json['seasonName'],
      events: List<String>.from(json['events']),
      leaderboard: Map<String, int>.from(json['leaderboard']),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seasonId': seasonId,
      'seasonName': seasonName,
      'events': events,
      'leaderboard': leaderboard,
      'isActive': isActive,
    };
  }
}
