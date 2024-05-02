import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:wrestle_predict/services/firestore_service.dart';
import 'package:collection/collection.dart';

import '../../models/event_model.dart';
import '../../models/match.dart';
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
    // addMatches(widget.event.matches);
    pickedWinner = List.filled(widget.event.matches.length, '-');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirestoreService fs = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: fs.getListMatchesFromFirebase(widget.event.matches),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                documents = snapshot.data!.docs;
                return Column(
                  children: [
                    _buildMatchessGridView(context, documents.isNotEmpty ? documents : []),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        backgroundColor: Colors.grey[500]!,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        //Add method for save changes.
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
      ),
    );
  }

  Widget _buildMatchessGridView(BuildContext context, List<DocumentSnapshot> matches) {
    final snapshotMatches =
        matches.mapIndexed((index, element) => _buildMatchCardItem(context, element, index)).toList();

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

  void addMatches(List<String> matches) {
    FirestoreService fs = FirestoreService();
    var match1 = Match(
        matchTitle: 'WWE Championship Match',
        matchId: uuid.v1(),
        participants: getMatchParticipatis(matches[1]),
        winner: "-",
        eventId: widget.event.eventId,
        graphicLink:
            "https://www.wwe.com/f/styles/wwe_16_9_xl/public/all/2024/04/20240416_BacklashFrance_Match_CodyAJ_FC_Date--ae1d439c811df35ed36d587a77fa8092.jpg");
    fs.addMatch(match1);

    var match2 = Match(
        matchTitle: 'World Heavyweight Championship Match',
        matchId: uuid.v1(),
        participants: getMatchParticipatis(matches[2]),
        winner: "-",
        eventId: widget.event.eventId,
        graphicLink:
            "https://www.wwe.com/f/styles/wwe_16_9_xl/public/all/2024/04/20240422_BacklashFrance_Match_DamianJey_FC_Date--18637444bf98f1f300dfd60d244753a2.jpg");
    fs.addMatch(match2);

    var match3 = Match(
        matchTitle: 'WWE Women\'s Championship Match',
        matchId: uuid.v1(),
        participants: getMatchParticipatis(matches[3]),
        winner: "-",
        eventId: widget.event.eventId,
        graphicLink:
            "https://www.wwe.com/f/styles/wwe_16_9_xl/public/all/2024/04/20240426_BacklashFrance_Match_WomensTripleThreat_FC_Date--4383eaddc3dcdb73c7d054e38f3d422f.jpg");
    fs.addMatch(match3);

    var match4 = Match(
        matchTitle: 'WWE Women\'s Tag Team Championship Match',
        matchId: uuid.v1(),
        participants: getMatchParticipatis(matches[4]),
        winner: "-",
        eventId: widget.event.eventId,
        graphicLink:
            "https://www.wwe.com/f/styles/wwe_16_9_xl/public/all/2024/04/20240426_BacklashFrance_Match_WomensTagTitles_FC_Date--2157d9770cbba3682c4692ad162fb07a.jpg");
    fs.addMatch(match4);

    var match5 = Match(
        matchId: uuid.v1(),
        participants: getMatchParticipatis(matches[0]),
        winner: "-",
        eventId: widget.event.eventId,
        graphicLink:
            "https://www.wwe.com/f/styles/wwe_16_9_xl/public/all/2024/04/20240426_BacklashFrance_Match_KORandy_SoloTonga_FC_Date--add45912a18ed93ce5571a42559dcc21.jpg");
    fs.addMatch(match5);
  }
}

List<String> getMatchParticipatis(String match) {
  List<String> participants = match.split(",");
  for (var p in participants) {
    p.trim();
  }

  return participants;
}
