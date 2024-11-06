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
            // Cambiato per tornare alla pagina delle impostazioni
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text('Fatti i cazzi tuoi con tanto amore'),
      ),
    );
  }
}
