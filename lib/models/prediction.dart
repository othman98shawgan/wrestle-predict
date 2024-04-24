class Prediction {
  final String predictionId;
  final String matchId;
  final String userId;
  final int pointsEarned;
  final String predictedWinner;

  Prediction({
    required this.predictionId,
    required this.matchId,
    required this.userId,
    required this.pointsEarned,
    required this.predictedWinner,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      predictionId: json['predictionId'],
      matchId: json['matchId'],
      userId: json['userId'],
      pointsEarned: json['pointsEarned'],
      predictedWinner: json['predictedWinner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predictionId': predictionId,
      'matchId': matchId,
      'userId': userId,
      'pointsEarned': pointsEarned,
      'predictedWinner': predictedWinner,
    };
  }
}
