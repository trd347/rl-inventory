import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rl_inventory/managers/inventory_manager.dart';
import 'package:rl_inventory/pages/containers_page.dart' as containers_page;

class Object {
  String name;
  String description;
  String containerName;

  Object({
    required this.name,
    required this.description,
    this.containerName = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'containerName': containerName,
    };
  }

  factory Object.fromJson(Map<String, dynamic> json) {
    return Object(
      name: json['name'],
      description: json['description'],
      containerName: json['containerName'] ?? '',
    );
  }
}

class ObjectsPage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Function(List<Object>) onObjectsUpdated;
  final Function updateInventory;
  final List<containers_page.Container> containers;

  ObjectsPage({
    required this.flutterLocalNotificationsPlugin,
    required this.onObjectsUpdated,
    required this.updateInventory,
    required this.containers,
  });

  @override
  _ObjectsPageState createState() => _ObjectsPageState();
}

class _ObjectsPageState extends State<ObjectsPage> {
  List<Object> _objects = [];
  final InventoryManager _inventoryManager = InventoryManager();

  @override
  void initState() {
    super.initState();
    _loadObjects();
    _inventoryManager.addListener(_updateUI);
  }

  @override
  void dispose() {
    _inventoryManager.removeListener(_updateUI);
    super.dispose();
  }

  Future<void> _loadObjects() async {
    List<Map<String, dynamic>> objectsData =
        await _inventoryManager.loadObjects();
    setState(() {
      _objects = objectsData.map((data) => Object.fromJson(data)).toList();
    });
  }

  Future<void> _saveObjects() async {
    List<Map<String, dynamic>> objectsData =
        _objects.map((object) => object.toJson()).toList();
    await _inventoryManager.saveObjects(objectsData);
    widget.onObjectsUpdated(_objects);
    widget.updateInventory();
  }

  void _updateUI() {
    _loadObjects();
  }

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

  Future<bool> _checkAndRequestPermissions() async {
    var status = await [
      Permission.notification,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
    return status.values.every((permission) => permission.isGranted);
  }

  Future<void> _addObject(String name, String description,
      {String containerName = ''}) async {
    setState(() {
      _objects.add(Object(
          name: name, description: description, containerName: containerName));
    });
    _saveObjects();

    if (await _checkAndRequestPermissions()) {
      _showNotification(
          'New Object Added', '$name has been added to your objects.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification permission denied')),
      );
    }
  }

  void _showAddObjectDialog() {
    String name = '';
    String description = '';
    String? selectedContainer;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Object'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedContainer,
                items: widget.containers
                    .map((container) => DropdownMenuItem<String>(
                          value: container.name,
                          child: Text(container.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedContainer = value;
                  });
                },
                hint: Text("Select a container"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && description.isNotEmpty) {
                  _addObject(
                    name,
                    description,
                    containerName: selectedContainer ?? '',
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: Text('Add'),
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
            subtitle: Text(_objects[index].description +
                (_objects[index].containerName.isNotEmpty
                    ? ' (In container: ${_objects[index].containerName})'
                    : '')),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Object'),
                    content:
                        Text('Are you sure you want to delete this object?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _objects.removeAt(index);
                          });
                          _saveObjects();
                          Navigator.of(context).pop();
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddObjectDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
