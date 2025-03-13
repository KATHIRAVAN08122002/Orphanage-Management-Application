import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  DateTime? selectedDate;

  void selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  String? validateInput() {
    if (nameController.text.trim().isEmpty) return 'Name cannot be empty';
    if (phoneController.text.length != 10) return 'Phone number must be 10 digits';
    if (!emailController.text.contains('@')) return 'Invalid email format';
    if (passwordController.text.length < 6) return 'Password must be at least 6 characters';
    if (passwordController.text != confirmPasswordController.text) return 'Passwords do not match';
    if (selectedDate == null) return 'Please select your date of birth';
    return null;
  }

  void signup(BuildContext context) async {
    final error = validateInput();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'userId': userId,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'dateOfBirth': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'donations': []  // Initialize an empty array for future donations
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup Failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Phone (10 digits)')),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '',
              ),
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: IconButton(icon: Icon(Icons.calendar_today), onPressed: () => selectDate(context)),
              ),
            ),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: confirmPasswordController, decoration: InputDecoration(labelText: 'Confirm Password'), obscureText: true),
            SizedBox(height: 16),
            ElevatedButton(onPressed: () => signup(context), child: Text('Sign Up')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
              child: Text('Already a user? Login now'),
            ),
          ],
        ),
      ),
    );
  }
}
