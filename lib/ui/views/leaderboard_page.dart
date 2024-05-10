import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wrestle_predict/services/firestore_service.dart';

bool isMobile = GetPlatform.isMobile;

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

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
        actions: [],
      ),
      body: FutureBuilder(
        future: fs.getCurrentSeasonLeaderboard(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LinearProgressIndicator();
          Map<String, int> leaderboard = snapshot.data ?? {};
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Center(
                  child: DataTable(
                    border: TableBorder.all(
                      width: 1.0,
                      color: Colors.white,
                    ),
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Expanded(
                          child: Text('Player'),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text('Score'),
                        ),
                      ),
                    ],
                    rows: leaderboard.entries.sorted((a, b) => b.value.compareTo(a.value)).map((entry) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(entry.key)),
                          DataCell(Text(entry.value.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
