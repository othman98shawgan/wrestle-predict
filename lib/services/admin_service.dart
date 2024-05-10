import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:wrestle_predict/models/event_model.dart';
import 'package:wrestle_predict/models/user_model.dart';

import '../models/season.dart';
import '../models/match.dart';
import 'firestore_service.dart';

final FirestoreService fs = FirestoreService();

showNewSeasonDialog(BuildContext context) async {
  final TextEditingController seasonNameController = TextEditingController(text: "");
  List<UserModel> users;
  List<UserModel> selectedUsers = [];

  var confirmMethod = (() async {
    fs.getAllUsers().then((users) {
      Season newSeason = Season(
        seasonId: const Uuid().v1(),
        seasonName: seasonNameController.text,
        events: [],
        leaderboard: {for (var user in selectedUsers) user.uid: 0},
        isActive: true,
        users: selectedUsers.map((user) => user.uid).toList(),
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
        return FutureBuilder(
          future: fs.getAllUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            users = snapshot.data!;
            final _items =
                users.map((user) => MultiSelectItem<UserModel>(user, "${user.firstName} ${user.lastName}")).toList();

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
                  child: Container(
                      constraints: const BoxConstraints(minWidth: 400, maxWidth: 600, maxHeight: 120, minHeight: 50),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: MultiSelectDialogField<UserModel>(
                        title: const Text('All Users'),
                        buttonText: const Text('Select Users'),
                        chipDisplay: MultiSelectChipDisplay(scroll: true),
                        dialogHeight: MediaQuery.of(context).size.height * 0.4,
                        dialogWidth: MediaQuery.of(context).size.width * 0.4,
                        confirmText: Text('Confirm',
                            style: TextStyle(color: Theme.of(context).buttonTheme.colorScheme!.primary)),
                        cancelText:
                            Text('Cancel', style: TextStyle(color: Theme.of(context).buttonTheme.colorScheme!.primary)),
                        itemsTextStyle: TextStyle(color: Colors.grey.shade500),
                        selectedItemsTextStyle: const TextStyle(color: Colors.white),
                        items: _items,
                        onConfirm: (values) {
                          selectedUsers = values;
                        },
                      )),
                ),
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

showAddEventDialog(BuildContext context) async {
  final TextEditingController seasonNameController = TextEditingController(text: "");
  final TextEditingController eventNameController = TextEditingController(text: "");
  final TextEditingController graphicLinkController = TextEditingController(text: "");
  var seasons = await fs.getAllSeasons();
  late Season pickedSeason;

  var confirmMethod = (() async {
    var graphic = graphicLinkController.text.isEmpty ? matchImagePlaceHolder : graphicLinkController.text;
    Event newEvent = Event(
      eventId: const Uuid().v1(),
      eventName: eventNameController.text,
      matches: [],
      seasonId: pickedSeason.seasonId,
      graphicLink: graphic,
      leaderboard: {for (var user in await fs.getAllUsersFromSeason(pickedSeason.seasonId)) user.uid: 0},
      userPicks: {for (var user in await fs.getAllUsersFromSeason(pickedSeason.seasonId)) user.uid: <String, String>{}},
    );
    fs.addEvent(newEvent);
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

showAddMatchDialog(BuildContext context) async {
  final TextEditingController participantsController = TextEditingController(text: "");
  final TextEditingController matchTitleController = TextEditingController(text: "");
  final TextEditingController eventNameController = TextEditingController(text: "");
  final TextEditingController graphicLinkController = TextEditingController(text: "");

  List<Event> events;
  late Event pickedEvent;

  var confirmMethod = (() async {
    var graphic = graphicLinkController.text.isEmpty ? matchImagePlaceHolder : graphicLinkController.text;
    var match = Match(
      matchId: const Uuid().v1(),
      participants: participantsController.text.split(',').map((e) => e.trim()).toList(),
      winner: "",
      eventId: pickedEvent.eventId,
      graphicLink: graphic,
      matchTitle: matchTitleController.text,
    );

    fs.addMatch(match);

    Navigator.pop(context);
  });

  AlertDialog alert = AlertDialog(
      title: const Text('Add New Match'),
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
          future: fs.getAllEvents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            events = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 400, maxWidth: 600, maxHeight: 100, minHeight: 50),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    controller: matchTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Match Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(minWidth: 400, maxWidth: 600, maxHeight: 100, minHeight: 50),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    controller: participantsController,
                    decoration: const InputDecoration(
                      labelText: 'Participants (Comma Separated)',
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
                    controller: eventNameController,
                    requestFocusOnTap: true,
                    label: const Text('Event Name'),
                    onSelected: (Event? event) {
                      setState(() {
                        pickedEvent = event!;
                      });
                    },
                    dropdownMenuEntries: events.map<DropdownMenuEntry<Event>>((Event event) {
                      return DropdownMenuEntry<Event>(
                        value: event,
                        label: event.eventName,
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
