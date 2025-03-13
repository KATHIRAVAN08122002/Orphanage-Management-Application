import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'donate_food_page.dart';
import 'donate_money_page.dart';
import 'appointment_screen.dart';

class OrphanageDetailPage extends StatelessWidget {
  final String orphanageId;

  OrphanageDetailPage({required this.orphanageId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orphanage Details"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orphanages').doc(orphanageId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Orphanage not found"));
          }

          var orphanageData = snapshot.data!.data() as Map<String, dynamic>;
          String title = orphanageData['name'] ?? "Unknown Orphanage";

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                orphanageData['image'] != null && orphanageData['image'].isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    orphanageData['image'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.broken_image, size: 60, color: Colors.grey[700]),
                        ),
                      );
                    },
                  ),
                )
                    : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.image, size: 60, color: Colors.grey[700]),
                  ),
                ),

                SizedBox(height: 16),

                // Name
                Text(
                  title,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // Place
                Text(
                  orphanageData['place'] ?? "Unknown Location",
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                SizedBox(height: 12),

                // About Section
                Text(
                  "About",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  orphanageData['about'] ?? 'No description available',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 16),

                // Address Section
                Text(
                  "Address",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  "${orphanageData['flat_no'] ?? 'N/A'}, ${orphanageData['street'] ?? 'N/A'}, "
                      "${orphanageData['city'] ?? 'N/A'}, ${orphanageData['state'] ?? 'N/A'}",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 8),

                // Mobile Number
                Text(
                  "Mobile: ${orphanageData['mobile'] ?? 'N/A'}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20),

                // Donation & Appointment Buttons
                Text(
                  "Support the Orphanage",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Donate Money
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonateMoneyPage(title: title),
                        ),
                      ),
                      icon: Icon(Icons.monetization_on, color: Colors.white),
                      label: Text("Donate Money"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Donate Food
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonateFoodPage(orphanageTitle: title),
                        ),
                      ),
                      icon: Icon(Icons.food_bank, color: Colors.white),
                      label: Text("Donate Food"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Book an Appointment
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentScreen(orphanageTitle: title),
                        ),
                      ),
                      icon: Icon(Icons.calendar_today, color: Colors.white),
                      label: Text("Book an Appointment"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}