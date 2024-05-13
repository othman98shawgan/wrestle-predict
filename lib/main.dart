import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:wrestle_predict/services/auth.dart';
import 'package:wrestle_predict/ui/auth/sign_up_page.dart';
import 'package:wrestle_predict/ui/auth/sign_in_page.dart';
import 'package:wrestle_predict/ui/views/leaderboard_page.dart';
import 'services/firebase_options.dart';

import 'package:wrestle_predict/ui/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRepository.instance()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialRoute: AuthRepository.instance().isConnected ? '/home' : '/signIn',
      routes: {
        '/signIn': (context) => const SignInPage(),
        '/signUp': (context) => const SignUpPage(),
        '/seasonLeaderboard': (context) => const LeaderboardPage(type: 'Season'),
        '/eventLeaderboard': (context) => const LeaderboardPage(type: 'Event'),
        '/home': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
      },
    );
  }
}
