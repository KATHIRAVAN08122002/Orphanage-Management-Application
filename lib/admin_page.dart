
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orphanage_detail_page.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orphanage_detail_page.dart';

class AdminPage extends StatefulWidget {
  final String userEmail;
  const AdminPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    // Only allow access to admin
    if (widget.userEmail != "admin@gmail.com") {
      return Scaffold(
        appBar: AppBar(title: Text("Access Denied")),
        body: Center(child: Text("You are not authorized to view this page.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Admin - Verify Orphanages")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('verification').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var orphanages = snapshot.data!.docs;
          if (orphanages.isEmpty) return Center(child: Text("No orphanages pending verification."));

          return ListView.builder(
            itemCount: orphanages.length,
            itemBuilder: (context, index) {
              var orphanage = orphanages[index];
              return Card(
                margin: EdgeInsets.all(10),
                elevation: 3,
                child: ListTile(
                  leading: orphanage['image'] != null
                      ? Image.network(orphanage['image'], width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 50),
                  title: Text(orphanage['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(orphanage['place']),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Map<String, dynamic> orphanageData = orphanage.data() as Map<String, dynamic>;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrphanageDetailPage(orphanageId: orphanage.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
