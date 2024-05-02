import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wrestle_predict/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:wrestle_predict/services/firestore_service.dart';

import '../models/event_model.dart';
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
  int _counter = -1;
  List<DocumentSnapshot> documents = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    counterDoc.set({'count': _counter}).onError((e, _) {
      print("Error writing document: $e");
    });
  }

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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50),
            StreamBuilder<QuerySnapshot>(
              stream: fs.getEventsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();
                documents = snapshot.data!.docs;
                return _buildEventsGridView(context, documents.isNotEmpty ? documents : []);
              },
            ),
          ],
        ),
      ),
    );
  }
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
