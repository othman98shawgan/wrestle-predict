import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wrestle_predict/services/firestore_service.dart';

bool isMobile = GetPlatform.isMobile;

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key, required this.type});

  final String type;

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

FirebaseFirestore db = FirebaseFirestore.instance;

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<DocumentSnapshot> documents = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 20,
        title: Image.asset('images/wrestle_predict_logo_1920_500.png', width: isMobile ? 240 : 360, fit: BoxFit.cover),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: widget.type == 'Season' ? fs.getCurrentSeason() : fs.getCurrentEvent(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LinearProgressIndicator();
          var data = snapshot.data ?? {};
          return FutureBuilder(
            future: widget.type == 'Season'
                ? fs.getSeasonLeaderboardToDisplay(getLeaderboard(data))
                : fs.getEventLeaderboardToDisplay(getLeaderboard(data)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              Map<String, int> leaderboard = snapshot.data ?? {};
              return Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '${getTitle(data)} Leaderboard',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text('Player',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text('Score',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                      columnSpacing: 100,
                      headingRowHeight: 80,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 55,
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                      ),
                      dataTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                      rows: leaderboard.entries.sorted((a, b) => b.value.compareTo(a.value)).map((entry) {
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Center(child: Text(entry.key)),
                            ),
                            DataCell(Center(child: Text(entry.value.toString()))),
                          ],
                        );
                      }).toList(),
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  String getTitle(dynamic data) {
    if (widget.type == 'Season') {
      return data.seasonName;
    } else {
      return data.eventName;
    }
  }

  String getId(dynamic data) {
    if (widget.type == 'Season') {
      return data.seasonId;
    } else {
      return data.eventId;
    }
  }

  Map<String, int> getLeaderboard(dynamic data) {
    return data.leaderboard;
  }
}
