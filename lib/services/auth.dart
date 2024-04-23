import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'firestore_service.dart';

enum Status { unInitialized, authenticated, authenticating, unAuthenticated }

class AuthRepository with ChangeNotifier {
  final FirebaseAuth _auth;
  final FirestoreService _firestoreService = FirestoreService();
  User? _user;
  Status _status = Status.unInitialized;

  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
  }

  Status get status => _status;
  User? get user => _user;

  Future<bool> signUp(String email, String password, String firstName, String lastName) async {
    try {
      _status = Status.authenticating;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      _user = _auth.currentUser;
      if (_user == null) {
        _status = Status.unAuthenticated;
        notifyListeners();
        return false;
      }
      _user!.updateDisplayName('$firstName $lastName');

      UserModel user = UserModel(uid: _user!.uid, email: _user!.email!, firstName: firstName, lastName: lastName);
      await _firestoreService.addUser(user);

      _status = Status.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
      }
    }
    _status = Status.unAuthenticated;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _user = _auth.currentUser;
      _status = Status.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        if (kDebugMode) {
          print('Wrong Email/Password combination.');
        }
      }
    }
    _status = Status.unAuthenticated;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
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
