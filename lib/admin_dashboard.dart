import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orphanage_detail_page.dart';
import 'login_screen.dart';
import 'unverified_orphanage_screen.dart';
import 'admin_profile_screen.dart';


class AdminDashboard extends StatefulWidget {
  final String userEmail;
  const AdminDashboard({Key? key, required this.userEmail}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userEmail != "admin@gmail.com") {
      return Scaffold(
        appBar: AppBar(title: Text("Access Denied")),
        body: Center(child: Text("You are not authorized to view this page.")),
      );
    }

    final List<Widget> _screens = [
      UnverifiedOrphanagesScreen(),
      AdminProfileScreen(logout: () => logout(context)),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
