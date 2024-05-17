import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:wrestle_predict/services/auth.dart';
import 'package:wrestle_predict/services/firestore_service.dart';

import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import 'views/event_page.dart';
import 'widgets/event_card.dart';

bool isMobile = GetPlatform.isMobile;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

FirebaseFirestore db = FirebaseFirestore.instance;

class _MyHomePageState extends State<MyHomePage> {
  final counterDoc = db.collection('counter').doc('counter');
  List<DocumentSnapshot> documents = [];
  AuthRepository authRepository = AuthRepository.instance();
  late Event currentEvent;
  late UserModel currentUser;
  bool isUserConnectedToCurrentEvent = false;

  @override
  void initState() {
    super.initState();
    // final authRepository = Provider.of<AuthRepository>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!authRepository.isConnected) {
        Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
      }
      fs.getCurrentEvent().then((value) {
        setState(() {
          currentEvent = value;
        });
        if (currentUser.isAdmin) {
          isUserConnectedToCurrentEvent = true;
        } else {
          fs.getSeason(currentEvent.seasonId).then((value) {
            if (value.users.contains(currentUser.uid)) {
              setState(() {
                isUserConnectedToCurrentEvent = true;
              });
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();

    if (!authRepository.isConnected) {
      return const Scaffold(
        body: Center(),
      );
    }

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
                Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
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
          currentUser = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text('Welcome to Wrestle Predict!'),
                const SizedBox(height: 30),
                _buildLeaderboardButtons(context, buttonStyle),
                const SizedBox(height: 10),
                currentUser.isAdmin
                    ? Column(
                        children: [
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              showSetCurrentSeasonDialog(context);
                            },
                            child: const Text('Set currnet Season'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              showSetCurrentEventDialog(context);
                            },
                            child: const Text('Set currnet Event'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              showNewSeasonDialog(context);
                            },
                            child: const Text('Create new Season'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              showAddEventDialog(context);
                            },
                            child: const Text('Add Event'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              showAddMatchDialog(context);
                            },
                            child: const Text('Add Match'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              showAddUserDialog(context);
                            },
                            child: const Text('Add User'),
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
      user: currentUser,
    );
  }

  Widget _buildLeaderboardButtons(BuildContext context, ButtonStyle buttonStyle) {
    if (isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: buttonStyle,
            onPressed: () {
              Navigator.pushNamed(context, "/seasonLeaderboard");
            },
            child: const Text('Season Leaderboard'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () {
              if (isUserConnectedToCurrentEvent) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EventPage(event: currentEvent)));
              } else {
                Fluttertoast.showToast(
                    msg: "Not connected to this event. Please ask Admin to add you.",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    webBgColor: '#C80000',
                    webPosition: 'center',
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            },
            child: const Text('Current Event'),
          ),
        ],
      );
    }
    return Row(
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
            if (isUserConnectedToCurrentEvent) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EventPage(event: currentEvent)));
            } else {
              Fluttertoast.showToast(
                  msg: "Not connected to this event. Please ask Admin to add you.",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  webBgColor: '#C80000',
                  webPosition: 'center',
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          },
          child: const Text('Current Event'),
        ),
      ],
    );
  }
}
