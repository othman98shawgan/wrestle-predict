import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wrestle_predict/models/user_model.dart';
import '../../models/event_model.dart';
import '../../services/firestore_service.dart';
import '../views/event_page.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.event, required this.user});

  final Event event;
  final UserModel user;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  FirestoreService fs = FirestoreService();

  late Event event;
  late UserModel currentUser;
  bool isUserConnectedToEvent = false;

  @override
  void initState() {
    event = widget.event;
    currentUser = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fs.getSeason(event.seasonId).then((value) {
        if (value.users.contains(currentUser.uid)) {
          setState(() {
            isUserConnectedToEvent = true;
          });
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isUserConnectedToEvent) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EventPage(event: event)));
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
      splashColor: Colors.black54,
      child: Ink(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              event.graphicLink,
            ),
            fit: BoxFit.fitWidth,
          ),
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                  color: Colors.black.withOpacity(0.9)),
              child: Text(
                event.eventName,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
