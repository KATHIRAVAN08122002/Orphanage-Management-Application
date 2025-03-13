import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orphanage_detail_page.dart';

class UnverifiedOrphanagesScreen extends StatelessWidget {
  void verifyOrphanage(String orphanageId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot orphanageDoc =
    await firestore.collection('verification').doc(orphanageId).get();

    if (orphanageDoc.exists) {
      Map<String, dynamic> orphanageData =
      orphanageDoc.data() as Map<String, dynamic>;

      // Set verified to true
      orphanageData['verified'] = true;

      // Move to orphanages collection
      await firestore.collection('orphanages').doc(orphanageId).set(orphanageData);

      // Delete from verification collection
      await firestore.collection('verification').doc(orphanageId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unverified Orphanages'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('verification')
            .where('verified', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No unverified orphanages found.'));
          }

          var orphanages = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: orphanages.length,
            itemBuilder: (context, index) {
              var orphanage = orphanages[index];
              Map<String, dynamic> orphanageData =
              orphanage.data() as Map<String, dynamic>;

              String title = orphanageData['title'] ?? 'No Title';
              String subtitle = "${orphanageData['city'] ?? 'Unknown'}, ${orphanageData['state'] ?? 'Unknown'}";

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.home, color: Colors.white),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrphanageDetailPage(
                          orphanageId: orphanage.id,
                        ),
                      ),
                    );
                  },
                  trailing: ElevatedButton(
                    onPressed: () {
                      verifyOrphanage(orphanage.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Verify', style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
