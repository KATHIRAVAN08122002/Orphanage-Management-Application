import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  // Fetching user data from Firestore based on UID
  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid; // Use UID for the document ID
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        } else {
          // Handle the case where the document does not exist
          return {};
        }
      } catch (e) {
        // Handle any Firestore errors
        throw Exception('Error fetching user data: $e');
      }
    } else {
      // Handle the case where the user is not authenticated
      throw Exception('User not authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No user data found'));
        } else {
          var userData = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${userData['name'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Mobile: ${userData['mobile'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('DOB: ${userData['dob'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Email: ${userData['email'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }
      },
    );
  }
}
