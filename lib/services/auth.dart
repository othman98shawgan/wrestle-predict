import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'firestore_service.dart';

enum Status { unInitialized, authenticated, authenticating, unAuthenticated }

class AuthRepository with ChangeNotifier {
  final FirebaseAuth auth;
  final FirestoreService _firestoreService = FirestoreService();
  User? _user;
  Status _status = Status.unInitialized;

  AuthRepository.instance() : auth = FirebaseAuth.instance {
    auth.authStateChanges().listen(_onAuthStateChanged);
    _user = auth.currentUser;
  }

  Status get status => _status;
  User? get user => _user;
  String? get displayName => _user?.displayName;

  bool get isAuthenticated => status == Status.authenticated;

  Future<bool> signUp(String email, String password, String firstName, String lastName) async {
    try {
      _status = Status.authenticating;
      notifyListeners();

      await auth.createUserWithEmailAndPassword(email: email, password: password).then((value) {
        auth.currentUser!.updateDisplayName('$firstName $lastName');
        _user = auth.currentUser;
        if (_user == null) {
          _status = Status.unAuthenticated;
          notifyListeners();
          return false;
        }

        UserModel user = UserModel(uid: _user!.uid, email: _user!.email!, firstName: firstName, lastName: lastName);
        _firestoreService.addUser(user);

        _status = Status.authenticated;
        notifyListeners();
      });
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.message != null) {
        throw e.message!;
      }
      _status = Status.unAuthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();

      await auth.signInWithEmailAndPassword(email: email, password: password);

      _user = auth.currentUser;
      _status = Status.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw 'Wrong Email/Password combination.';
      }
      if (e.message != null) {
        throw e.message!;
      }
      _status = Status.unAuthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    _user = null;
    _status = Status.unAuthenticated;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.unAuthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.authenticated;
    }
    notifyListeners();
  }
}
