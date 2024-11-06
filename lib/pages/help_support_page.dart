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
            // Cambiato per tornare alla pagina delle impostazioni
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text('arrangiati, puoi facerla da solo-a'),
      ),
    );
  }
}
