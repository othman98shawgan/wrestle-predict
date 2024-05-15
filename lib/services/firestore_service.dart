import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../models/match.dart';
import '../models/season.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference seasonsCollection = FirebaseFirestore.instance.collection('seasons');
  final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');
  final CollectionReference matchesCollection = FirebaseFirestore.instance.collection('matches');
  final CollectionReference globalCollection = FirebaseFirestore.instance.collection('global');

  //***** User Methods *****
  Future<void> addUser(UserModel user) async {
    return await usersCollection.doc(user.uid).set(user.toJson());
  }

  Future<UserModel> getUser(String uid) async {
    UserModel user = UserModel.empty();
    await usersCollection.doc(uid).get().then((userSnapshot) {
      user = UserModel.fromJson(userSnapshot.data() as Map<String, dynamic>);
    });
    return user;
  }

  Future<List<UserModel>> getAllUsers() async {
    List<UserModel> users = [];

    await usersCollection.get().then((value) {
      for (var doc in value.docs) {
        users.add(UserModel.fromJson(doc.data() as Map<String, dynamic>));
      }
    });

    return users;
  }

  Future<List<UserModel>> getAllUsersFromSeason(String seasonId) async {
    List<UserModel> users = [];

    await seasonsCollection.doc(seasonId).get().then((value) async {
      Season seaosn = Season.fromJson(value.data() as Map<String, dynamic>);
      var userIdList = seaosn.users;
      for (var userId in userIdList) {
        UserModel user = await getUser(userId);
        users.add(user);
      }
    });

    return users;
  }

  //***** Season Methods *****
  Future<void> addSeason(Season season) async {
    return await seasonsCollection.doc(season.seasonId).set(season.toJson());
  }

  Future<Season> getSeason(String uid) async {
    late Season season;
    await seasonsCollection.doc(uid).get().then((seasonSnapshot) {
      season = Season.fromJson(seasonSnapshot.data() as Map<String, dynamic>);
    });
    return season;
  }

  Future<List<Season>> getAllSeasons() async {
    List<Season> seasons = [];

    await seasonsCollection.get().then((value) {
      for (var doc in value.docs) {
        seasons.add(Season.fromJson(doc.data() as Map<String, dynamic>));
      }
    });

    return seasons;
  }

  Future<void> addEventToSeason(String eventId, String seasonId) {
    List<String> eventAsList = [eventId];
    return seasonsCollection.doc(seasonId).update({"events": FieldValue.arrayUnion(eventAsList)});
  }

  Future<void> addUserToSeason(UserModel user, Season season) async {
    List<String> userAsList = [user.uid];
    await seasonsCollection
        .doc(season.seasonId)
        .update({"users": FieldValue.arrayUnion(userAsList), "leaderboard.${user.uid}": 0}).then((value) {
      for (var event in season.events) {
        eventsCollection.doc(event).update({"leaderboard.${user.uid}": 0});
      }
    });
  }

  Future<void> updateSeasonLeaderboard(String seasonId, Map<String, int> leaderboard) {
    return seasonsCollection.doc(seasonId).update({"leaderboard": leaderboard});
  }

  Future<Map<String, int>> getSeasonLeaderboard(String seasonId) async {
    Map<String, int> leaderboard = {};
    await seasonsCollection.doc(seasonId).get().then((seasonSnapshot) {
      Season season = Season.fromJson(seasonSnapshot.data() as Map<String, dynamic>);
      leaderboard = season.leaderboard;
    });

    return leaderboard;
  }

  //***** Event Methods *****
  Future<List<Event>> getAllEvents() async {
    List<Event> events = [];

    await eventsCollection.get().then((value) {
      for (var doc in value.docs) {
        events.add(Event.fromJson(doc.data() as Map<String, dynamic>));
      }
    });

    return events;
  }

  Future<Event> getEvent(String uid) async {
    late Event event;
    await eventsCollection.doc(uid).get().then((snapshot) {
      event = Event.fromJson(snapshot.data() as Map<String, dynamic>);
    });
    return event;
  }

  Stream<QuerySnapshot> getEventsStream() {
    return eventsCollection.snapshots();
  }

  Stream<DocumentSnapshot> getEventFromFirebase(String eventId) {
    return eventsCollection.doc(eventId).snapshots();
  }

  Future<void> addEvent(Event event) async {
    addEventToSeason(event.eventId, event.seasonId);
    return await eventsCollection.doc(event.eventId).set(event.toJson());
  }

  Future<void> updateEventLeaderboard(String eventId, Map<String, int> leaderboard) {
    return eventsCollection.doc(eventId).update({"leaderboard": leaderboard});
  }

  Future<Map<String, int>> getEventLeaderboard(String eventId) async {
    Map<String, int> leaderboard = {};
    await eventsCollection.doc(eventId).get().then((eventSnapshot) {
      Event event = Event.fromJson(eventSnapshot.data() as Map<String, dynamic>);
      leaderboard = event.leaderboard;
    });

    return leaderboard;
  }

  //***** Match Methods *****
  Stream<DocumentSnapshot> getMatchFromFirebase(String matchId) {
    return matchesCollection.doc(matchId).snapshots();
  }

  Stream<QuerySnapshot> getListMatchesFromFirebase(List<String> matchIds) {
    return matchesCollection.where(FieldPath.documentId, whereIn: matchIds).get().asStream();
  }

  Future<void> addMatch(Match match) async {
    addMatchtoEvent(match.matchId, match.eventId);
    await matchesCollection.doc(match.matchId).set(match.toJson());
  }

  Future<void> addMatchtoEvent(String matchId, String eventId) {
    List<String> matchAsList = [matchId];
    return eventsCollection.doc(eventId).update({"matches": FieldValue.arrayUnion(matchAsList)});
  }

  //Result Methods
  Future<void> addResultToMatch(String matchId, String result) {
    return matchesCollection.doc(matchId).update({"winner": result});
  }

  Future<void> addUserPicksToEvent(String eventId, String userId, Map<String, String> picks) {
    return eventsCollection.doc(eventId).update({"userPicks.$userId": picks});
  }

  Future<String> getMatchWinner(String matchId) async {
    String winner = '';
    await matchesCollection.doc(matchId).get().then((matchSnapshot) {
      Match match = Match.fromJson(matchSnapshot.data() as Map<String, dynamic>);
      winner = match.winner;
    });

    return winner;
  }

  //Leaderboard Methods
  Future<void> updateLeaderboard(String eventId, String seasonId, Map<String, int> newLeaderboard) async {
    getSeasonLeaderboard(seasonId).then((seasonLeaderboard) {
      getEventLeaderboard(eventId).then((eventLeaderboard) {
        seasonLeaderboard.forEach((key, value) {
          if (eventLeaderboard.containsKey(key)) {
            seasonLeaderboard[key] = seasonLeaderboard[key]! - eventLeaderboard[key]!;
            seasonLeaderboard[key] = seasonLeaderboard[key]! + newLeaderboard[key]!;
          }
        });
        updateEventLeaderboard(eventId, newLeaderboard);
        updateSeasonLeaderboard(seasonId, seasonLeaderboard);
      });
    });
  }

  Future<Map<String, int>> getCurrentSeasonLeaderboard() async {
    var currSeasonId = '';
    Map<String, int> resLeaderboard;
    late Map<String, int> userNameLeaderboard = {};
    await globalCollection.doc('currSeason').get().then((data) async {
      currSeasonId = (data.data() as Map<String, dynamic>)['seasonId'];
      await getSeasonLeaderboard(currSeasonId).then((leaderboard) async {
        resLeaderboard = leaderboard;
        for (var key in resLeaderboard.keys) {
          await getUser(key).then((value) {
            userNameLeaderboard['${value.firstName} ${value.lastName}'] = resLeaderboard[key]!;
          });
        }
      });
    });
    return userNameLeaderboard;
  }

  Future<Map<String, int>> getCurrentEventLeaderboard() async {
    var currEventId = '';
    Map<String, int> resLeaderboard;
    late Map<String, int> userNameLeaderboard = {};
    await globalCollection.doc('currEvent').get().then((data) async {
      currEventId = (data.data() as Map<String, dynamic>)['eventId'];
      await getEventLeaderboard(currEventId).then((leaderboard) async {
        resLeaderboard = leaderboard;
        for (var key in resLeaderboard.keys) {
          await getUser(key).then((value) {
            userNameLeaderboard['${value.firstName} ${value.lastName}'] = resLeaderboard[key]!;
          });
        }
      });
    });
    return userNameLeaderboard;
  }

  Future<Map<String, int>> getSeasonLeaderboardToDisplay(Map<String, int> leaderboard) async {
    Map<String, int> resLeaderboard;
    late Map<String, int> userNameLeaderboard = {};
    resLeaderboard = leaderboard;
    for (var key in resLeaderboard.keys) {
      await getUser(key).then((value) {
        userNameLeaderboard['${value.firstName} ${value.lastName}'] = resLeaderboard[key]!;
      });
    }

    return userNameLeaderboard;
  }

  Future<Map<String, int>> getEventLeaderboardToDisplay(Map<String, int> leaderboard) async {
    Map<String, int> resLeaderboard;
    late Map<String, int> userNameLeaderboard = {};
    resLeaderboard = leaderboard;
    for (var key in resLeaderboard.keys) {
      await getUser(key).then((value) {
        userNameLeaderboard['${value.firstName} ${value.lastName}'] = resLeaderboard[key]!;
      });
    }

    return userNameLeaderboard;
  }

  Future<Season> getCurrentSeason() async {
    var currSeasonId = '';
    late Season res;
    await globalCollection.doc('currSeason').get().then((data) async {
      currSeasonId = (data.data() as Map<String, dynamic>)['seasonId'];
      await getSeason(currSeasonId).then((season) async {
        res = season;
      });
    });
    return res;
  }

  Future<Event> getCurrentEvent() async {
    var currEventId = '';
    late Event res;
    await globalCollection.doc('currEvent').get().then((data) async {
      currEventId = (data.data() as Map<String, dynamic>)['eventId'];
      await getEvent(currEventId).then((event) async {
        res = event;
      });
    });
    return res;
  }

  Future<void> setCurrentSeason(String seasonId) async {
    return await globalCollection.doc('currSeason').set({"seasonId": seasonId});
  }

  Future<void> setCurrentEvent(String eventId) async {
    return await globalCollection.doc('currEvent').set({"eventId": eventId});
  }

  //Generic Methods
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  Future<void> updateData(String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).update(data);
  }

  Future<void> deleteData(String collection, String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  Stream<List<T>> getData<T>(String collection, T Function(Map<String, dynamic> data) fromJson) {
    return _db.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
    });
  }
}
