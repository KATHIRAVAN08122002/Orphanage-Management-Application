import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orphanage_detail_page.dart';
import 'package:intl/intl.dart';

class AdminProfileScreen extends StatelessWidget {
  final VoidCallback logout;
  const AdminProfileScreen({Key? key, required this.logout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: logout,
          child: Text('Logout'),
        ),
      ),
    );
  }
}
