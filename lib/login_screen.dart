// Enhanced Login and Signup Screens with Responsive UI and Improved Design

// login_screen.dart
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
                TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
                SizedBox(height: 20),
                ElevatedButton(onPressed: () => login(context), child: Text('Login')),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                  child: Text('New user? Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}