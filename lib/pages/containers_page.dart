import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Importa il pacchetto per notifiche
import 'package:permission_handler/permission_handler.dart'; // Importa il pacchetto per la gestione dei permessi

class MyContainer {
  String name;
  String description;
  List<String> items;

  MyContainer({required this.name, required this.description}) : items = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'items': items,
    };
  }

  factory MyContainer.fromJson(Map<String, dynamic> json) {
    return MyContainer(
      name: json['name'],
      description: json['description'],
    )..items = List<String>.from(json['items'] ?? []);
  }
}

class ContainersPage extends StatefulWidget {
  final Function updateInventory; // Funzione di callback

  // Passiamo updateInventory al costruttore
  ContainersPage({required this.updateInventory});

  @override
  _ContainersPageState createState() => _ContainersPageState();
}

class _ContainersPageState extends State<ContainersPage> {
  List<MyContainer> _containers = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadContainers();
    _initializeNotifications(); // Inizializza le notifiche
  }

  // Funzione per inizializzare le notifiche
  void _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> _loadContainers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? containersJson = prefs.getString('containers');
    if (containersJson != null) {
      List<dynamic> decoded = json.decode(containersJson);
      setState(() {
        _containers =
            decoded.map((json) => MyContainer.fromJson(json)).toList();
      });
      widget.updateInventory(
          _containers); // Aggiorniamo l'inventario nella homepage
    }
  }

  Future<void> _saveContainers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encoded = json
        .encode(_containers.map((container) => container.toJson()).toList());
    await prefs.setString('containers', encoded);
  }

  // Funzione per aggiungere un contenitore
  Future<void> _addContainer(String name, String description) async {
    setState(() {
      _containers.add(MyContainer(name: name, description: description));
      _saveContainers();
      widget
          .updateInventory(_containers); // Aggiorna l'inventario nella homepage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added!')),
      );
    });

    if (await _checkAndRequestPermissions()) {
      _showNotification(
          'New Container Added', '$name has been added to your containers.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification permission denied')),
      );
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    } else {
      var result = await Permission.notification.request();
      return result.isGranted;
    }
  }

  void _showContainerDialog(String name, String description, {int? index}) {
    final nameController = TextEditingController(text: name);
    final descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Add Container' : 'Edit Container'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (index == null) {
                  _addContainer(
                      nameController.text, descriptionController.text);
                } else {
                  _editContainer(
                      index, nameController.text, descriptionController.text);
                }
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

  void _editContainer(int index, String name, String description) {
    setState(() {
      _containers[index].name = name;
      _containers[index].description = description;
      _saveContainers();
      widget.updateInventory(
          _containers); // Aggiorniamo l'inventario nella homepage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_containers[index].name} updated!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Containers'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showContainerDialog('', ''),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _containers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_containers[index].name),
            subtitle: Text(_containers[index].description),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  _showContainerDialog(
                      _containers[index].name, _containers[index].description,
                      index: index);
                } else if (value == 'Remove') {
                  _removeContainer(index);
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Remove'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          );
        },
      ),
    );
  }

  void _removeContainer(int index) {
    String name = _containers[index].name;
    setState(() {
      _containers.removeAt(index);
      _saveContainers();
      widget.updateInventory(
          _containers); // Aggiorniamo l'inventario nella homepage
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name removed!')),
    );
  }
}
