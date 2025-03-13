import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user's ID
  Future<String?> getUserId() async {
    return _auth.currentUser?.uid;
  }

  // Fetch user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  // Store donation information
  Future<void> storeDonation(String userId, Map<String, dynamic> donationData) async {
    try {
      print("User ID: $userId");
      print("Donation Data: $donationData");

      // Store in donor_information collection
      await _firestore.collection('donor_information').add({
        'userId': userId,
        ...donationData,
        'timestamp': FieldValue.serverTimestamp(), // Assign timestamp here
      });

      // Reference to the user document
      DocumentReference userRef = _firestore.collection('users').doc(userId);

      // Ensure donations field exists
      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        print("User document does not exist! Creating one...");
        await userRef.set({'donations': []});
      }

      // Generate timestamp separately
      Timestamp serverTimestamp = Timestamp.now(); // Avoid FieldValue.serverTimestamp() inside arrayUnion

      // Append donation in users collection under 'donations'
      await userRef.update({
        'donations': FieldValue.arrayUnion([
          {
            'type': 'amount',
            'amount': donationData['amount'],
            'timestamp': serverTimestamp, // Use pre-generated timestamp
          }
        ])
      });

      print("Donation successfully stored in user's document.");
    } catch (e) {
      print("Error storing donation: $e");
    }
  }



}
