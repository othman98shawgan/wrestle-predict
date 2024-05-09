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

  //***** Season Methods *****
  Future<void> addSeason(Season season) async {
    return await seasonsCollection.doc(season.seasonId).set(season.toJson());
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
