import 'package:flutter/material.dart';

class TagConfigurationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tag Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Configure your NFC tags',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            // Logica per configurare i tag NFC
            ElevatedButton(
              onPressed: () {
                // Logica per salvare le configurazioni dei tag
              },
              child: Text('Save Configuration'),
            ),
          ],
        ),
      ),
    );
  }
}
