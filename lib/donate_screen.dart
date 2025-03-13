import 'package:demo/appointment_screen.dart';
import 'package:demo/donate_food_page.dart';
import 'package:demo/donate_money_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donate')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DonateMoneyPage(title: 'orpha'),
                ),
              ),
              child: Text('Donate Money'),
            ),

            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => DonateFoodPage(orphanageTitle: 'Default Title'))),
              child: Text('Donate Food'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AppointmentScreen(orphanageTitle: 'Default Title'))),
              child: Text('Book an Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
