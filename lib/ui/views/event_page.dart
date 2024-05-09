import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
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
  List<DocumentSnapshot> documents = [];

  @override
  void initState() {
    pickedWinner = List.filled(widget.event.matches.length, '-');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirestoreService fs = FirestoreService();
    final authRepository = Provider.of<AuthRepository>(context);

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
                              if (currentUser.isAdmin) {
                                for (var i = 0; i < documents.length; i++) {
                                  fs.addResultToMatch(documents[i].id, pickedWinner[i]);
                                }
                                //Add method for saving winners.
                              } else {
                                //Add method for saving prediction.
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
      padding: const EdgeInsets.all(12.0),
      mainAxisSpacing: 10.0,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 2,
          child: MatchCard(
            match: match,
          ),
        ),
        Expanded(
          flex: 1,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            crossAxisCount: match.participants.length >= 4 ? 2 : 1,
            childAspectRatio: match.participants.length >= 4 ? 5 : 10,
            padding: const EdgeInsets.all(12.0),
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            children: List<Widget>.generate(match.participants.length, (index) {
              return GridTile(
                child: RadioListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text(match.participants[index]),
                  groupValue: pickedWinner[matchIndex],
                  value: match.participants[index],
                  onChanged: (value) {
                    setState(() {
                      pickedWinner[matchIndex] = value.toString();
                    });
                  },
                ),
              );
            }),
          ),
        ),
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
                setState(() {
                  pickedWinner[matchIndex] = value!;
                });
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
