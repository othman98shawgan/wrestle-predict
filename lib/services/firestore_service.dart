import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../models/match.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');
  final CollectionReference matchesCollection = FirebaseFirestore.instance.collection('matches');

  //User Methods
  Future<void> addUser(UserModel user) async {
    return await usersCollection.doc(user.uid).set(user.toJson());
  }

  //***** User Methods *****
  Future<UserModel> getUser(String uid) async {
    UserModel user = UserModel.empty();
    await usersCollection.doc(uid).get().then((userSnapshot) {
      user = UserModel.fromJson(userSnapshot.data() as Map<String, dynamic>);
    });
    return user;
  }

  //***** Event Methods *****
  Stream<QuerySnapshot> getEventsStream() {
    return eventsCollection.snapshots();
  }

  Stream<DocumentSnapshot> getEventFromFirebase(String eventId) {
    return eventsCollection.doc(eventId).snapshots();
  }

  Future<DocumentReference> addEvent(Event event) {
    return eventsCollection.add(event.toJson());
  }

  //***** Match Methods *****
  Stream<DocumentSnapshot> getMatchFromFirebase(String matchId) {
    return matchesCollection.doc(matchId).snapshots();
  }

  Stream<QuerySnapshot> getListMatchesFromFirebase(List<String> matchIds) {
    return matchesCollection.where(FieldPath.documentId, whereIn: matchIds).get().asStream();
  }

  Future<void> addMatch(Match match) async {
    await matchesCollection.doc(match.matchId).set(match.toJson());
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
