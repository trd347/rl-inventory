import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
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
            Text('For support, please contact us at:'),
            SizedBox(height: 10),
            Text('Email: support@example.com'),
            SizedBox(height: 10),
            Text('FAQ Section:'),
            ElevatedButton(
              onPressed: () {
                // Aggiungi logica per visualizzare FAQ
              },
              child: Text('View FAQs'),
            ),
          ],
        ),
      ),
    );
  }
}
