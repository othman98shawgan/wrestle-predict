import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
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
