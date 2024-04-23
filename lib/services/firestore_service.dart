import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  //User Methods
  Future<void> addUser(UserModel user) async {
    return await usersCollection.doc(user.uid).set(user.toJson());
  }

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
