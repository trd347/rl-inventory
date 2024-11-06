import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rl_inventory/pages/home_page.dart'; // Importa la HomePage
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart'; // Importa la libreria NFC
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Importa il plugin delle notifiche
import 'package:permission_handler/permission_handler.dart'; // Importa il pacchetto per la gestione dei permessi

class Object {
  String name;
  String description;

  Object({required this.name, required this.description});

  // Metodo per convertire un oggetto in un formato JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  // Metodo per creare un oggetto da un formato JSON
  factory Object.fromJson(Map<String, dynamic> json) {
    return Object(
      name: json['name'],
      description: json['description'],
    );
  }
}

class ObjectsPage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Function(List<Object>)
      onObjectsUpdated; // Callback per aggiornare la HomePage

  ObjectsPage(
      {required this.flutterLocalNotificationsPlugin,
      required this.onObjectsUpdated});

  @override
  _ObjectsPageState createState() => _ObjectsPageState();
}

class _ObjectsPageState extends State<ObjectsPage> {
  List<Object> _objects = [];

  @override
  void initState() {
    super.initState();
    _loadObjects();
  }

  // Carica gli oggetti da SharedPreferences
  void _loadObjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('objects');
    if (jsonString != null) {
      List<dynamic> jsonList = json.decode(jsonString);
      _objects = jsonList.map((json) => Object.fromJson(json)).toList();
      setState(() {});
    }
  }

  // Salva gli oggetti in SharedPreferences
  void _saveObjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString =
        json.encode(_objects.map((object) => object.toJson()).toList());
    await prefs.setString('objects', jsonString);
  }

  // Funzione per inviare la notifica
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

  // Funzione per verificare e richiedere i permessi di notifica
  Future<bool> _checkAndRequestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    } else {
      var result = await Permission.notification.request();
      return result.isGranted;
    }
  }

  // Funzione per aggiungere un oggetto con notifica
  Future<void> _addObject(String name, String description) async {
    setState(() {
      _objects.add(Object(name: name, description: description));
      _saveObjects();
      widget.onObjectsUpdated(
          _objects); // Passa gli oggetti aggiornati a HomePage
    });

    // Controlla e richiedi i permessi prima di mostrare la notifica
    if (await _checkAndRequestPermissions()) {
      _showNotification(
          'New Object Added', '$name has been added to your objects.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification permission denied')),
      );
    }
  }

  void _editObject(int index, String name, String description) {
    setState(() {
      _objects[index].name = name;
      _objects[index].description = description;
      _saveObjects();
      widget.onObjectsUpdated(
          _objects); // Passa gli oggetti aggiornati a HomePage
    });
  }

  void _removeObject(int index) {
    setState(() {
      _objects.removeAt(index);
      _saveObjects();
      widget.onObjectsUpdated(
          _objects); // Passa gli oggetti aggiornati a HomePage
    });
  }

  Future<void> _scanNFC() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Scanning..."),
            ],
          ),
        );
      },
    );

    try {
      NFCTag tag = await FlutterNfcKit.poll();
      String scannedName = 'Object - ${tag.id}';
      String scannedDescription = 'Description for the scanned object';

      _addObject(scannedName, scannedDescription);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$scannedName added!')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan NFC tag: $e')),
      );
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  void _showEditDialog(int index) {
    String name = _objects[index].name;
    String description = _objects[index].description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Object'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                controller: TextEditingController(text: name),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                controller: TextEditingController(text: description),
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _editObject(index, name, description);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Funzione per tornare alla homepage
  void goBackToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          flutterLocalNotificationsPlugin:
              widget.flutterLocalNotificationsPlugin,
          updateInventory: (List<Object> objects) {
            // Qui puoi definire il comportamento per l'aggiornamento dell'inventario
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Objects'),
        actions: [
          IconButton(
            icon: Icon(Icons.nfc),
            onPressed: _scanNFC,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _objects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_objects[index].name),
            subtitle: Text(_objects[index].description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showEditDialog(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeObject(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
