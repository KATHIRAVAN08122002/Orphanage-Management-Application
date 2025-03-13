import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  ProfileScreen({required this.userEmail});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.userEmail)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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
            List<dynamic> donations = userData['donations'] ?? [];

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${userData['name'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Phone: +91 ${userData['phone'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('DOB: ${userData['dateOfBirth'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Email: ${userData['email'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Donation History:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  SizedBox(height: 10),
                  donations.isEmpty
                      ? Center(child: Text('No donations made yet'))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      var donation = donations[index];
                      String donationType = donation['type'] ?? 'N/A';
                      String orphanageTitle = donation['orphanageTitle'] ?? 'N/A';
                      String donationDetail = donationType.toLowerCase() == 'food'
                          ? 'Number of Parcels: ${donation['numberOfParcels'] ?? 'N/A'}'
                          : 'Amount: ₹${donation['amount'] ?? 'N/A'}';

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            'Type: $donationType',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                          subtitle: Text(
                            '$donationDetail\nOrphanage: $orphanageTitle\nDate: ${_formatDate(donation['timestamp'])}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('dd-MM-yyyy').format(date);
    }
    return 'N/A';
  }
}
