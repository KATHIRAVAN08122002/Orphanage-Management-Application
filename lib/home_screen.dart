// Home Screen with Navigation to Orphanage Detail
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'feedback_screen.dart';
import 'orphanage_detail_screen.dart';
import 'upload_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Pages for bottom navigation
  final List<Widget> _pages = [
    HomeContent(),    // Home Page Content
    ProfileScreen(),  // Profile Page
    UploadPage(),   // Upload Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuItemSelected,
            itemBuilder: (_) => {'About', 'Contact', 'Feedback'}
                .map((choice) => PopupMenuItem(
              value: choice.toLowerCase(),
              child: Text(choice),
            ))
                .toList(),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Upload'),
        ],
      ),
    );
  }

  void _onMenuItemSelected(String value) {
    if (value == 'feedback') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FeedbackScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(value),
          content: Text('This is a sample $value page.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

// Separate Home Content Widget for Cleaner Code
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrphanageDetailScreen(
                    title: orphanage['title'],
                    place: orphanage['place'],
                    image: orphanage['image'],
                  ),
                ),
              ),
              child: Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                child: Column(
                  children: [
                    Image.network(
                      orphanage['image'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset('assets/placeholder.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${orphanage['title']}, ${orphanage['place']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
