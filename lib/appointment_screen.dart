import 'package:flutter/material.dart';

class AppointmentScreen extends StatelessWidget {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Appointment')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Time'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save appointment in Firestore
              },
              child: Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
