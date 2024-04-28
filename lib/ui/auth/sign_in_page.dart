import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wrestle_predict/services/auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController(text: "");
  final TextEditingController passwordController = TextEditingController(text: "");
  bool isPasswordVisible = false;

  String email = '${DateTime.now().millisecondsSinceEpoch}@gmail.com';
  String password = '1234567890';
  String firstName = 'Othman';
  String lastName = 'Shawgan';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthRepository>(context);

    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Image(width: 720, image: AssetImage('images/wrestle_predict_logo_1920_300.png')),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In to your account',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              const Text(
                "Or ",
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/signUp");
                  },
                  child: const Text(
                    "Create a new account",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.only(right: 10),
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                auth.signInWithEmailAndPassword(emailController.text, passwordController.text).then((value) {
                  if (value) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                }).onError((error, stackTrace) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.green),
              onPressed: () async {
                await auth
                    .signUp(email, password, firstName, lastName)
                    .whenComplete(() => Navigator.pushReplacementNamed(context, '/home'));
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
