import 'package:flutter/material.dart';

class GroupsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Groups')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Group 1'),
              onTap: () {
                // Naviga a una pagina di dettagli del gruppo
              },
            ),
            ListTile(
              title: Text('Group 2'),
              onTap: () {
                // Naviga a una pagina di dettagli del gruppo
              },
            ),
            // Aggiungi altri gruppi come necessario
            ElevatedButton(
              onPressed: () {
                // Logica per aggiungere un nuovo gruppo
              },
              child: Text('Create New Group'),
            ),
          ],
        ),
      ),
    );
  }
}
