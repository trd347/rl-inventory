import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:rl_inventory/managers/inventory_manager.dart';

class HomePage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Function updateInventory;

  HomePage({
    required this.flutterLocalNotificationsPlugin,
    required this.updateInventory,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> containers = [];
  List<String> objects = [];
  late List<ContainerWithObjects> containersWithObjects = [];
  final InventoryManager _inventoryManager = InventoryManager();

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
    _inventoryManager
        .addListener(_updateUI); // Aggiunge il listener per aggiornare la UI
  }

  @override
  void dispose() {
    _inventoryManager.removeListener(
        _updateUI); // Rimuove il listener quando la pagina viene distrutta
    super.dispose();
  }

  // Funzione per caricare i dati dell'inventario da InventoryManager
  Future<void> _loadInventoryData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Caricamento dei contenitori
      String? containersJson = prefs.getString('containers');
      List<dynamic> containersList =
          containersJson != null ? json.decode(containersJson) : [];

      // Verifica che containersList sia una lista prima di convertirla
      if (containersList is List) {
        containers = List<String>.from(containersList);
      } else {
        throw Exception(
            'Errore: il formato dei dati dei contenitori non è valido.');
      }

      // Caricamento degli oggetti
      String? objectsJson = prefs.getString('objects');
      List<dynamic> objectsList =
          objectsJson != null ? json.decode(objectsJson) : [];

      // Verifica che objectsList sia una lista prima di convertirla
      if (objectsList is List) {
        objects = List<String>.from(objectsList);
      } else {
        throw Exception(
            'Errore: il formato dei dati degli oggetti non è valido.');
      }

      // Caricamento degli oggetti nei contenitori
      String? objectsInContainersJson = prefs.getString('objectsInContainers');
      Map<String, dynamic> objectsInContainers = objectsInContainersJson != null
          ? Map<String, dynamic>.from(json.decode(objectsInContainersJson))
          : {};

      if (mounted) {
        setState(() {
          containersWithObjects.clear();
          containersWithObjects.addAll(containers.map((container) {
            return ContainerWithObjects(
              name: container,
              objects: objectsInContainers[container] != null
                  ? List<String>.from(objectsInContainers[container])
                  : [],
            );
          }));
        });
      }
    } catch (e) {
      print('Errore durante il caricamento dei dati dell inventario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Errore durante il caricamento dei dati dell inventario: $e')),
        );
      }
    }
  }

  // Funzione per aggiornare la UI quando l'inventario viene modificato
  void _updateUI() {
    _loadInventoryData(); // Richiama il caricamento dei dati per aggiornare la UI
  }

  // Funzione per aggiornare i dati dell'inventario
  void updateInventoryData(
      List<String> updatedContainers,
      Map<String, List<String>> updatedObjectsInContainers,
      List<String> updatedObjects) {
    if (mounted) {
      setState(() {
        containers = updatedContainers;
        containersWithObjects.clear();
        containersWithObjects.addAll(updatedContainers.map((container) {
          return ContainerWithObjects(
            name: container,
            objects: updatedObjectsInContainers[container] ?? [],
          );
        }));
        objects = updatedObjects;
      });
    }
  }

  // Funzione per mostrare una notifica
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'Description of your channel',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await widget.flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: Theme.of(context).textTheme.titleLarge),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Sezione INVENTARIO
            Text(
              'INVENTARIO',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Sezione Containers
            ExpansionTile(
              title: Text('Containers',
                  style: Theme.of(context).textTheme.bodyLarge),
              children: containersWithObjects.isNotEmpty
                  ? containersWithObjects.map((containerWithObjects) {
                      return ExpansionTile(
                        title: Text(containerWithObjects.name,
                            style: Theme.of(context).textTheme.bodyMedium),
                        children: containerWithObjects.objects.map((object) {
                          return ListTile(
                            title: Text(object,
                                style: Theme.of(context).textTheme.bodyMedium),
                          );
                        }).toList(),
                      );
                    }).toList()
                  : [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No containers available',
                            style: Theme.of(context).textTheme.bodyMedium),
                      )
                    ],
            ),

            const SizedBox(height: 20),

            // Sezione Objects
            ExpansionTile(
              title:
                  Text('Objects', style: Theme.of(context).textTheme.bodyLarge),
              children: objects.isNotEmpty
                  ? objects.map((object) {
                      return ListTile(
                        title: Text(object,
                            style: Theme.of(context).textTheme.bodyMedium),
                      );
                    }).toList()
                  : [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No objects available',
                            style: Theme.of(context).textTheme.bodyMedium),
                      )
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerWithObjects {
  final String name;
  final List<String> objects;

  ContainerWithObjects({
    required this.name,
    required this.objects,
  });
}
