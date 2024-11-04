import 'package:flutter/material.dart';

class TagManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tag Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Tag 1'),
              onTap: () {
                // Naviga a una pagina di dettagli del tag
              },
            ),
            ListTile(
              title: Text('Tag 2'),
              onTap: () {
                // Naviga a una pagina di dettagli del tag
              },
            ),
            // Aggiungi altri tag come necessario
            ElevatedButton(
              onPressed: () {
                // Logica per aggiungere un nuovo tag
              },
              child: Text('Add New Tag'),
            ),
          ],
        ),
      ),
    );
  }
}
