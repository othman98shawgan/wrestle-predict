import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wrestle_predict/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:wrestle_predict/services/firestore_service.dart';

import '../models/event_model.dart';
import '../services/admin_service.dart';
import 'widgets/event_card.dart';

bool isMobile = GetPlatform.isMobile;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

FirebaseFirestore db = FirebaseFirestore.instance;

class _MyHomePageState extends State<MyHomePage> {
  final counterDoc = db.collection('counter').doc('counter');
  List<DocumentSnapshot> documents = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();

    final authRepository = Provider.of<AuthRepository>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 20,
        title: Image.asset('images/wrestle_predict_logo_1920_500.png', width: isMobile ? 240 : 360, fit: BoxFit.cover),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            padding: const EdgeInsets.all(8),
            offset: Offset(0, isMobile ? 34 : 58),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Profile',
                  child: Text(authRepository.auth.currentUser!.displayName ?? "Profile"),
                ),
                const PopupMenuItem(
                    value: 'signOut',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 10),
                        Text('Log Out'),
                      ],
                    )),
              ];
            },
            onSelected: (value) {
              if (value == 'signOut') {
                authRepository.signOut();
                Navigator.pushNamed(context, "/signIn");
              }
            },
            child: IconButton(
              icon: Icon(
                Icons.account_circle,
                size: isMobile ? 24 : 48,
              ),
              onPressed: null,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: fs.getUser(authRepository.user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LinearProgressIndicator();
          var currentUser = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: buttonStyle,
                      onPressed: () {
                        Navigator.pushNamed(context, "/seasonLeaderboard");
                      },
                      child: const Text('Season Leaderboard'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: buttonStyle,
                      onPressed: () {
                        Navigator.pushNamed(context, "/eventLeaderboard");
                      },
                      child: const Text('Current Event Leaderboard'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                currentUser!.isAdmin
                    ? Column(
                        children: [
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              //Add season method-dialog
                              showNewSeasonDialog(context);
                            },
                            child: const Text('Create new Season'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              //Add event method-dialog
                              showAddEventDialog(context);
                            },
                            child: const Text('Add Event'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              //Add match method-dialog
                              showAddMatchDialog(context);
                            },
                            child: const Text('Add Match'),
                          )
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 50),
                StreamBuilder<QuerySnapshot>(
                  stream: fs.getEventsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    documents = snapshot.data!.docs;
                    return _buildEventsGridView(context, documents.isNotEmpty ? documents : []);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(250, 0),
    padding: const EdgeInsets.symmetric(vertical: 16),
    foregroundColor: Colors.white,
  );
}

Widget _buildEventsGridView(BuildContext context, List<DocumentSnapshot>? snapshot) {
  final snapshotEvents = snapshot!.map((data) => _buildEventCardItem(context, data)).toList();
  return GridView.count(
    physics: const ScrollPhysics(),
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
    crossAxisCount: isMobile ? 2 : 6,
    childAspectRatio: 0.7,
    padding: const EdgeInsets.all(12.0),
    mainAxisSpacing: 10.0,
    crossAxisSpacing: 10.0,
    children: List<Widget>.generate(snapshotEvents.length, (index) {
      return GridTile(
        child: snapshotEvents[index],
      );
    }),
  );
}

Widget _buildEventCardItem(BuildContext context, DocumentSnapshot snapshot) {
  final event = Event.fromSnapshot(snapshot);
  return EventCard(
    event: event,
  );
}
