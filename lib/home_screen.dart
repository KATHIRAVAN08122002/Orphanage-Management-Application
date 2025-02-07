import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'feedback_screen.dart'; // Import the FeedbackScreen file
import 'orphanage_detail_screen.dart'; // Import the OrphanageDetailScreen file

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to handle the menu item selection
  void _onMenuItemSelected(String value) {
    if (value == 'feedback') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FeedbackScreen()),
      );
    } else {
      // Handle about and contact here (can show dialog or navigate to other pages)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(value),
            content: Text('This is a sample $value page.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _onMenuItemSelected,
            itemBuilder: (BuildContext context) {
              return {'About', 'Contact', 'Feedback'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice.toLowerCase(),
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orphanages').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data available.'));
          }

          final orphanages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orphanages.length,
            itemBuilder: (context, index) {
              final orphanage = orphanages[index];
              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  leading: Image.network(
                    orphanage['image'],
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/placeholder.png'); // Fallback image
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // Image loaded, show the image
                      } else {
                        return Center(child: CircularProgressIndicator()); // Loading indicator
                      }
                    },
                  ),
                  title: Text(orphanage['title']),
                  subtitle: Text(orphanage['place']),
                  onTap: () {
                    // Navigate to the orphanage details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrphanageDetailScreen(
                          title: orphanage['title'],
                          place: orphanage['place'],
                          image: orphanage['image'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      )
          : ProfileScreen(), // Navigate to ProfileScreen when second tab is selected
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
