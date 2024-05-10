class Season {
  final String seasonId;
  final String seasonName;
  final List<String> events;
  final Map<String, int> leaderboard;
  final bool isActive;
  final List<String> users;

  Season({
    required this.seasonId,
    required this.seasonName,
    required this.events,
    required this.leaderboard,
    required this.isActive,
    required this.users,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonId: json['seasonId'],
      seasonName: json['seasonName'],
      events: List<String>.from(json['events']),
      leaderboard: Map<String, int>.from(json['leaderboard']),
      isActive: json['isActive'],
      users: List<String>.from(json['users']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seasonId': seasonId,
      'seasonName': seasonName,
      'events': events,
      'leaderboard': leaderboard,
      'isActive': isActive,
      'users': users,
    };
  }
}
