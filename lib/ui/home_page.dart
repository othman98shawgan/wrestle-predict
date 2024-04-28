import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wrestle_predict/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

FirebaseFirestore db = FirebaseFirestore.instance;

class _MyHomePageState extends State<MyHomePage> {
  final counterDoc = db.collection('counter').doc('counter');
  int _counter = -1;
  bool isMobile = GetPlatform.isMobile;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    counterDoc.set({'count': _counter}).onError((e, _) {
      print("Error writing document: $e");
    });
  }

  @override
  void initState() {
    super.initState();
    getCounter();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context);
    String email = 'oth1998@gmail1.com';
    String password = '1234567890';
    String firstName = 'Othman';
    String lastName = 'Shawgan';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 20,
        title: Image.asset('images/wrestle_predict_logo_1920_500.png', width: isMobile ? 240 : 360, fit: BoxFit.cover),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            padding: const EdgeInsets.all(8),
            offset: Offset(0, isMobile ? 34 : 58),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Profile',
                  child: Text(authRepository.auth.currentUser!.displayName ?? "Profile"),
                ),
                const PopupMenuItem(
                    value: 'signOut',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 10),
                        Text('Log Out'),
                      ],
                    )),
              ];
            },
            onSelected: (value) {
              if (value == 'signOut') {
                authRepository.signOut();
                Navigator.pushNamed(context, "/signIn");
              }
            },
            child: IconButton(
              icon: Icon(
                Icons.account_circle,
                size: isMobile ? 24 : 48,
              ),
              onPressed: null,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            authRepository.user == null
                ? const Text('You are not logged in')
                : Text(authRepository.user!.email.toString()),
            const SizedBox(height: 20),
            Text(authRepository.status.toString()),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.green),
              onPressed: () {
                authRepository.signUp(email, password, firstName, lastName);
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.blue),
              onPressed: () {
                authRepository.signInWithEmailAndPassword(email, password);
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.red),
              onPressed: () {
                authRepository.signOut();
                Navigator.pushNamed(context, "/signIn");
              },
              child: const Text('Sign Out'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  void getCounter() {
    counterDoc.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _counter = data['count'];
        });
      }
    }).onError((e, _) {
      print("Error reading document: $e");
    });
  }
}
