import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wrestle_predict/services/auth.dart';
import 'package:provider/provider.dart';

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
    // TODO: implement initState
    super.initState();
    getCounter();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthRepository>(context);
    String email = 'oth1998@gmail.com';
    String password = '1234567890';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _counter == -1
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  auth.user == null ? const Text('You are not logged in') : Text(auth.user!.email.toString()),
                  SizedBox(height: 20),
                  Text(auth.status.toString()),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.green),
                    onPressed: () {
                      auth.signUp(email, password);
                    },
                    child: const Text('Sign Up'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.blue),
                    onPressed: () {
                      auth.signInWithEmailAndPassword(email, password);
                    },
                    child: const Text('Sign In'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.red),
                    onPressed: () {
                      auth.signOut();
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
