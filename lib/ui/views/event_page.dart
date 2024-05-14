import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:wrestle_predict/services/auth.dart';
import 'package:wrestle_predict/services/firestore_service.dart';
import 'package:collection/collection.dart';

import '../../models/event_model.dart';
import '../../models/match.dart';
import '../../models/user_model.dart';
import '../widgets/match_card.dart';

bool isMobile = GetPlatform.isMobile;
var uuid = const Uuid();

class EventPage extends StatefulWidget {
  const EventPage({super.key, required this.event});

  final Event event;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<String> pickedWinner = [];
  Map<String, String> pickedWinnerMap = {};
  List<DocumentSnapshot> documents = [];
  AuthRepository authRepository = AuthRepository.instance();

  @override
  void initState() {
    super.initState();
    pickedWinner = List.filled(widget.event.matches.length, '-');
    for (var match in widget.event.matches) {
      pickedWinnerMap[match] = widget.event.userPicks[authRepository.user!.uid]![match];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!authRepository.isConnected) {
        Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FirestoreService fs = FirestoreService();

    //Check if user is authenticated
    if (!authRepository.isConnected) {
      return const Scaffold(
        body: Center(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventName),
      ),
      body: FutureBuilder(
          future: fs.getUser(authRepository.user!.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            var currentUser = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: fs.getListMatchesFromFirebase(widget.event.matches),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      documents = snapshot.data!.docs;
                      return Column(
                        children: [
                          _buildMatchessGridView(context, documents.isNotEmpty ? documents : [], currentUser!),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              backgroundColor: Colors.grey[500]!,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              for (var i = 0; i < documents.length; i++) {
                                pickedWinnerMap[documents[i].id] = pickedWinner[i];
                              }
                              var event = widget.event;
                              if (currentUser.isAdmin) {
                                for (var i = 0; i < documents.length; i++) {
                                  fs.addResultToMatch(documents[i].id, pickedWinner[i]);
                                }
                                event.userPicks.forEach((key, userPick) {
                                  event.leaderboard[key] = 0;
                                  userPick.forEach((matchId, pick) {
                                    if (pickedWinnerMap[matchId] == pick) {
                                      event.leaderboard[key] = event.leaderboard[key]! + 1;
                                    }
                                  });
                                });

                                fs.updateLeaderboard(event.eventId, event.seasonId, event.leaderboard);
                                //Update event and Season Leaderboard
                              } else {
                                fs.addUserPicksToEvent(event.eventId, currentUser.uid, pickedWinnerMap);
                              }
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 20.0)
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildMatchessGridView(BuildContext context, List<DocumentSnapshot> matches, UserModel currentUser) {
    final List<Widget> snapshotMatches;
    if (currentUser.isAdmin) {
      snapshotMatches =
          matches.mapIndexed((index, element) => _buildAdminMatchCardItem(context, element, index)).toList();
    } else {
      snapshotMatches = matches.mapIndexed((index, element) => _buildMatchCardItem(context, element, index)).toList();
    }

    return GridView.count(
      physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      crossAxisCount: isMobile ? 1 : 3,
      childAspectRatio: 1,
      padding: const EdgeInsets.all(24.0),
      mainAxisSpacing: 20.0,
      crossAxisSpacing: 10.0,
      children: List<Widget>.generate(matches.length, (index) {
        return GridTile(
          child: snapshotMatches[index],
        );
      }),
    );
  }

  Widget _buildMatchCardItem(BuildContext context, DocumentSnapshot snapshot, int matchIndex) {
    final match = Match.fromSnapshot(snapshot);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 2,
          child: MatchCard(
            match: match,
          ),
        ),
        match.participants.length >= 3
            ? Expanded(
                flex: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(48, 0, 48, 0),
                    child: DropdownMenu<String>(
                      width: 200,
                      enableSearch: false,
                      enableFilter: false,
                      label: const Text('Winner', textAlign: TextAlign.center),
                      initialSelection: pickedWinnerMap[match.matchId],
                      onSelected: (String? value) {
                        pickedWinnerMap[match.matchId] = value!;
                        pickedWinner[matchIndex] = value;
                      },
                      dropdownMenuEntries: match.participants.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(value: value, label: value);
                      }).toList(),
                    ),
                  ),
                ),
              )
            : Expanded(
                flex: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(48, 0, 48, 0),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return RadioListTile(
                          visualDensity: VisualDensity.compact,
                          title: Text(match.participants[index]),
                          groupValue: pickedWinnerMap[match.matchId],
                          value: match.participants[index],
                          onChanged: (value) {
                            setState(() {
                              pickedWinner[matchIndex] = value.toString();
                              pickedWinnerMap[match.matchId] = value.toString();
                            });
                          },
                        );
                      },
                      itemCount: match.participants.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ),
                ),
              )
      ],
    );
  }

  Widget _buildAdminMatchCardItem(BuildContext context, DocumentSnapshot snapshot, int matchIndex) {
    final match = Match.fromSnapshot(snapshot);
    pickedWinner[matchIndex] = match.winner;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Expanded(
        flex: 2,
        child: MatchCard(
          match: match,
        ),
      ),
      Expanded(
        flex: 1,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 0),
            child: DropdownMenu<String>(
              enableSearch: false,
              enableFilter: false,
              label: const Text('Winner'),
              initialSelection: pickedWinner[matchIndex],
              onSelected: (String? value) {
                pickedWinner[matchIndex] = value!;
              },
              dropdownMenuEntries: match.participants.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
          ),
        ),
      ),
    ]);
  }
}

List<String> getMatchParticipatis(String match) {
  List<String> participants = match.split(",");
  for (var p in participants) {
    p.trim();
  }

  return participants;
}
