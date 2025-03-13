import 'package:flutter/material.dart';

class OrphanageDetailPage extends StatelessWidget {
  final Map<String, dynamic> orphanageData;

  OrphanageDetailPage({required this.orphanageData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(orphanageData['name'])),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            orphanageData['imageUrl'] != null
                ? Image.network(orphanageData['imageUrl']) // Display image
                : Container(),
            SizedBox(height: 16),
            Text(
              orphanageData['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              orphanageData['place'],
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              orphanageData['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
