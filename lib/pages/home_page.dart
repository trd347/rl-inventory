import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Function updateInventory;

  // Corretto il costruttore: I parametri sono richiesti e devono essere passati al costruttore tramite le parentesi graffe
  HomePage({
    required this.flutterLocalNotificationsPlugin, // Parametro obbligatorio per le notifiche
    required this.updateInventory, // Parametro obbligatorio per aggiornare l'inventario
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> containers = []; // Lista dei containers
  List<String> objects = []; // Lista degli oggetti
  final Map<String, List<String>> objectsInContainers =
      {}; // Oggetti all'interno dei containers

  // Funzione per aggiornare i dati dell'inventario
  void updateInventoryData(
      List<String> updatedContainers,
      Map<String, List<String>> updatedObjectsInContainers,
      List<String> updatedObjects) {
    setState(() {
      containers = updatedContainers;
      objectsInContainers.clear();
      objectsInContainers.addAll(updatedObjectsInContainers);
      objects = updatedObjects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        automaticallyImplyLeading: false, // Rimosso il tasto di ritorno
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Sezione INVENTARIO
            Text(
              'INVENTARIO',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight:
                      FontWeight.bold), // Modificato headline5 a headlineMedium
            ),
            const SizedBox(height: 20),

            // Sezione Containers
            ExpansionTile(
              title: Text('Containers'),
              children: containers.map((container) {
                return ExpansionTile(
                  title: Text(container),
                  children: objectsInContainers[container]!.map((object) {
                    return ListTile(
                      title: Text(object),
                    );
                  }).toList(),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Sezione Objects
            ExpansionTile(
              title: Text('Objects'),
              children: objects.map((object) {
                return ListTile(
                  title: Text(object),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
