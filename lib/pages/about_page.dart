import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Torna alla pagina precedente
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Real Life Inventory App'),
            SizedBox(height: 10),
            Text('Version: 1.0.0'),
            SizedBox(height: 10),
            Text('This app helps you manage your inventory effectively.'),
            SizedBox(height: 10),
            Text('Contact: support@example.com'),
          ],
        ),
      ),
    );
  }
}
