import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum Status { unInitialized, authenticated, authenticating, unAuthenticated }

class AuthRepository with ChangeNotifier {
  final FirebaseAuth _auth;
  User? _user;
  Status _status = Status.unInitialized;

  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
  }

  Status get status => _status;
  User? get user => _user;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      _status = Status.authenticated;
      notifyListeners();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
      } else if (e.code == 'email-already-in-use') {
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
      }
    }
    _status = Status.unAuthenticated;
    notifyListeners();
    return null;
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

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
