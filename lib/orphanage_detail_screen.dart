import 'package:flutter/material.dart';
import 'package:demo/donate_food_page.dart';
import 'package:demo/donate_money_page.dart';
import 'package:demo/appointment_screen.dart';


class OrphanageDetailScreen extends StatelessWidget {
  final String title;
  final String place;
  final String image;

  OrphanageDetailScreen({
    required this.title,
    required this.place,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying the orphanage image at the top
            Image.network(
              image,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            // Adding some padding for the title and place
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                place,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 20),
            // You can add more details or description about the orphanage here
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'About the Orphanage: \n\n'
                    'This is a brief description about the orphanage, its history, mission, and the services it provides to children in need. '
                    'You can add further information like contact details, the number of children housed, and how people can help.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonateMoneyPage(title: title),
                    ),
                  ),
                  child: Text('Donate Money'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonateFoodPage(orphanageTitle: title),
                    ),
                  ),
                  child: Text('Donate Food'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentScreen(orphanageTitle: title),
                    ),
                  ),
                  child: Text('Book an Appointment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
