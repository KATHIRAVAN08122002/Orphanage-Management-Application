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
      await firestore
          .collection('orphanages')
          .doc(orphanageId)
          .set(orphanageData);

      // Delete from verification collection
      await firestore.collection('verification').doc(orphanageId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unverified Orphanages')),
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
            itemCount: orphanages.length,
            itemBuilder: (context, index) {
              var orphanage = orphanages[index];
              Map<String, dynamic> orphanageData =
              orphanage.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(orphanageData['name']),
                  subtitle: Text(orphanageData['place']), // Ensure 'place' exists in Firestore
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrphanageDetailPage(
                          orphanageData: orphanageData, // Pass the data
                        ),
                      ),
                    );
                  },
                  trailing: ElevatedButton(
                    onPressed: () {
                      verifyOrphanage(orphanage.id);
                    },
                    child: Text('Verify'),
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
