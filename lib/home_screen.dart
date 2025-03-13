import 'package:demo/nearby_orphanage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'feedback_screen.dart';
import 'orphanage_detail_screen.dart';
import 'upload_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;

  const HomeScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Pages for bottom navigation
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(), // Home Page Content
      ProfileScreen(userEmail: widget.userEmail), // ✅ Pass userEmail to Profile
      NearbyOrphanagesPage(),
      UploadPage(), // Upload Page
    ];
  }

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
            itemBuilder: (_) => {'About', 'Contact', 'Feedback', 'Logout'}
                .map((choice) => PopupMenuItem(value: choice.toLowerCase(), child: Text(choice)))
                .toList(),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Nearby"),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Upload'),
        ],
      ),
    );
  }

  void _onMenuItemSelected(String value) {
    if (value == 'feedback') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => FeedbackScreen()));
    } else if (value == 'logout') {
      _logoutUser();
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(value.capitalize()),
          content: Text('This is the $value page. More details coming soon.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
          ],
        ),
      );
    }
  }

  // Logout Function
  Future<void> _logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout Failed: $e')));
    }
  }
}

// ✅ Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}

// Home Content Widget
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orphanages').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No orphanages available.'));
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
