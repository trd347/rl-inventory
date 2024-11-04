import 'package:flutter/material.dart';
import 'custom_drawer.dart'; // Assicurati di avere un file custom_drawer.dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: CustomDrawer(), // Il tuo menu a tendina
      body: Center(
        child: Text('Benvenuto alla Home Page!'),
      ),
    );
  }
}
