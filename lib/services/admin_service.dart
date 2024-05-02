import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:wrestle_predict/models/event_model.dart';

import '../models/season.dart';
import 'firestore_service.dart';

final FirestoreService fs = FirestoreService();

showNewSeasonDialog(BuildContext context) async {
  final TextEditingController seasonNameController = TextEditingController(text: "");

  var confirmMethod = (() async {
    fs.getAllUsers().then((users) {
      var leaderboard = {for (var user in users) '${user.firstName} ${user.lastName}': 0};

      Season newSeason = Season(
        seasonId: const Uuid().v1(),
        seasonName: seasonNameController.text,
        events: [],
        leaderboard: leaderboard,
        isActive: true,
      );

      fs.addSeason(newSeason);

      Fluttertoast.showToast(
          msg: "New Season Created!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });

    Navigator.pop(context);
  });

  AlertDialog alert = AlertDialog(
      title: const Text('Create New Season'),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 16.0),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: confirmMethod,
          child: const Text('Confirm'),
        ),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
              child: Container(
                constraints: const BoxConstraints(minWidth: 400, maxWidth: 600, maxHeight: 100, minHeight: 50),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextFormField(
                  controller: seasonNameController,
                  decoration: const InputDecoration(
                    labelText: 'Season Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ],
        );
      }));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showAddEventDialog(BuildContext context) async {
  final TextEditingController seasonNameController = TextEditingController(text: "");
  final TextEditingController eventNameController = TextEditingController(text: "");
  final TextEditingController graphicLinkController = TextEditingController(text: "");
  var seasons = await fs.getAllSeasons();
  late Season pickedSeason;

  var confirmMethod = (() async {
    Event newEvent = Event(
      eventId: const Uuid().v1(),
      eventName: eventNameController.text,
      matches: [],
      seasonId: pickedSeason.seasonId,
      graphicLink: graphicLinkController.text,
    );
    fs.addEvent(newEvent);
    fs.addEventToSeason(newEvent.eventId, pickedSeason.seasonId);
    Navigator.pop(context);
  });

  AlertDialog alert = AlertDialog(
      title: const Text('Add New Event'),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 16.0),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: confirmMethod,
          child: const Text('Confirm'),
        ),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return FutureBuilder(
          future: fs.getAllSeasons(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            seasons = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 400, maxWidth: 600, maxHeight: 100, minHeight: 50),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    controller: eventNameController,
                    decoration: const InputDecoration(
                      labelText: 'Event Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(minWidth: 400, maxWidth: 400, maxHeight: 100, minHeight: 50),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    controller: graphicLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Graphic Link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(minWidth: 400, maxWidth: 600, maxHeight: 100, minHeight: 50),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: DropdownMenu(
                    width: 360,
                    controller: seasonNameController,
                    requestFocusOnTap: true,
                    label: const Text('Season Name'),
                    onSelected: (Season? season) {
                      setState(() {
                        pickedSeason = season!;
                      });
                    },
                    dropdownMenuEntries: seasons.map<DropdownMenuEntry<Season>>((Season season) {
                      return DropdownMenuEntry<Season>(
                        value: season,
                        label: season.seasonName,
                      );
                    }).toList(),
                  ),
                )
              ],
            );
          },
        );
      }));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
