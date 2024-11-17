import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rl_inventory/pages/objects_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'; // Pacchetto per la gestione Bluetooth
import 'package:rl_inventory/bluetooth_manager.dart';
import 'package:rl_inventory/pages/container_details.dart';
import 'package:rl_inventory/managers/inventory_manager.dart';

class Container {
  String name;
  String description;
  List<String> objects;
  bool isConnected; // Stato della connessione Bluetooth

  Container({
    required this.name,
    required this.description,
    this.objects = const [],
    this.isConnected = false,
  });

  factory Container.fromJson(Map<String, dynamic> json) {
    var objectsFromJson = json['objects'] != null
        ? List<String>.from(json['objects'])
        : <String>[];
    return Container(
      name: json['name'] as String,
      description: json['description'] as String,
      objects: objectsFromJson,
      isConnected: json['isConnected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'objects': objects,
      'isConnected': isConnected,
    };
  }
}

class ContainersPage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Function(List<Container>) onContainersUpdated;
  final Function updateInventory;

  ContainersPage({
    required this.flutterLocalNotificationsPlugin,
    required this.onContainersUpdated,
    required this.updateInventory,
    required List<Object> objects,
  });

  @override
  _ContainersPageState createState() => _ContainersPageState();
}

Future<void> _clearPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Pulisci tutte le preferenze
  print("SharedPreferences cleared");
}

class _ContainersPageState extends State<ContainersPage> {
  List<Container> _containers = [];
  List<String> _objects = []; // Lista degli oggetti salvati
  final BluetoothManager _bluetoothManager = BluetoothManager();
  final InventoryManager _inventoryManager = InventoryManager();

  @override
  void initState() {
    super.initState();
    _loadContainers();
    _loadObjects(); // Carica gli oggetti salvati
    _inventoryManager
        .addListener(_updateUI); // Aggiunge un listener per aggiornare la UI
  }

  @override
  void dispose() {
    _inventoryManager.removeListener(
        _updateUI); // Rimuove il listener per evitare memory leaks
    super.dispose();
  }

  Future<void> _loadContainers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Caricamento dei contenitori
      String? containersJson = prefs.getString('containers');
      if (containersJson != null && containersJson.isNotEmpty) {
        List<dynamic> containersList = json.decode(containersJson);

        if (mounted) {
          setState(() {
            _containers = containersList.map((item) {
              if (item is Map<String, dynamic>) {
                return Container.fromJson(item);
              } else {
                throw Exception('Formato non valido per il contenitore');
              }
            }).toList();

            widget.onContainersUpdated(_containers);
            widget.updateInventory();
          });
        }
      }
    } catch (e) {
      print('Errore durante il caricamento dei contenitori: $e');
    }
  }

  Future<void> _loadObjects() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? objectsJson = prefs.getString('objects');
      if (objectsJson != null && objectsJson.isNotEmpty) {
        List<dynamic> objectsList = json.decode(objectsJson);

        if (mounted) {
          setState(() {
            _objects = List<String>.from(objectsList);
          });
        }
      }
    } catch (e) {
      print('Errore durante il caricamento degli oggetti: $e');
    }
  }

  Future<void> _saveContainers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String containersJson = json.encode(
        _containers.map((container) => container.toJson()).toList(),
      );
      await prefs.setString('containers', containersJson);

      if (mounted) {
        // Log di debug per verificare cosa viene salvato
        print('Dati salvati: $containersJson');
        widget.onContainersUpdated(_containers);
        widget.updateInventory();
      }
    } catch (e) {
      print('Errore durante il salvataggio dei contenitori: $e');
    }
  }

  // Funzione per aggiornare la UI quando l'inventario cambia
  void _updateUI() {
    if (mounted) {
      _loadContainers();
      _loadObjects();
    }
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
      payload: 'container x',
    );
  }

  Future<bool> _checkAndRequestPermissions() async {
    var status = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.notification
    ].request();
    return status.values.every((permission) => permission.isGranted);
  }

  Future<void> _addContainer(String name, String description) async {
    setState(() {
      _containers.add(Container(name: name, description: description));
    });

    await _saveContainers();

    if (await _checkAndRequestPermissions()) {
      await _showNotification(
          'New Container Added', '$name has been added to your containers.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification permission denied')),
      );
    }
  }

  void _editContainer(int index, String name, String description) {
    setState(() {
      _containers[index].name = name;
      _containers[index].description = description;
    });

    _saveContainers();
  }

  void _removeContainer(int index) {
    setState(() {
      _containers.removeAt(index);
    });

    _saveContainers();
  }

  // Funzione per aggiungere un oggetto a un contenitore
  void _addObjectToContainer(int containerIndex, String object) {
    setState(() {
      _containers[containerIndex].objects.add(object);
    });
    _saveContainers();
  }

  // Funzione per rimuovere un oggetto da un contenitore
  void _removeObjectFromContainer(int containerIndex, String object) {
    setState(() {
      _containers[containerIndex].objects.remove(object);
    });
    _saveContainers();
  }

  // Sincronizza la lista degli oggetti nei contenitori con gli oggetti rimanenti
  void _syncContainersWithObjects() {
    if (mounted) {
      setState(() {
        for (var container in _containers) {
          container.objects = container.objects
              .where((object) => _objects.contains(object))
              .toList();
        }
      });
      _saveContainers();
    }
  }

  void _showAddObjectDialog(int containerIndex) {
    String? selectedObject;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Object to ${_containers[containerIndex].name}'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                isExpanded: true,
                value: selectedObject,
                items: _objects
                    .map((obj) => DropdownMenuItem<String>(
                          value: obj,
                          child: Text(obj),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedObject = value;
                  });
                },
                hint: Text("Select an object"),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedObject != null) {
                  _addObjectToContainer(containerIndex, selectedObject!);
                  Navigator.of(context).maybePop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select an object')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(int index) {
    String name = _containers[index].name;
    String description = _containers[index].description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Container'),
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
                _editContainer(index, name, description);
                Navigator.of(context).maybePop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddContainerDialog() {
    String name = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Container'),
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && description.isNotEmpty) {
                  _addContainer(name, description);
                  Navigator.of(context).maybePop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Please provide both name and description')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _connectToBluetoothDevice(Container container) async {
    if (await _checkAndRequestPermissions()) {
      // Start scanning for Bluetooth devices
      _bluetoothManager.startScan((BluetoothDiscoveryResult result) {
        // Assicurati di controllare che il dispositivo trovato abbia un indirizzo MAC valido e non nullo
        if (result.device.address != null &&
            result.device.name == container.name) {
          // Fermiamo la scansione per evitare ulteriori risultati dopo aver trovato il dispositivo desiderato
          _bluetoothManager.stopScan();

          // Connettiamoci al dispositivo
          _bluetoothManager.connectToDevice(result.device, (bool? isConnected) {
            // Callback per gestire lo stato della connessione
            if (isConnected != null && isConnected) {
              if (mounted) {
                setState(() {
                  container.isConnected = true;
                });
                _saveContainers();
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to connect to ${container.name}'),
                ),
              );
            }
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bluetooth permission denied')),
      );
    }
  }

  void _navigateToContainerDetails(int containerIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContainerDetailsPage(
          container: _containers[containerIndex],
          objects: _objects,
          onObjectAdded: (object) {
            _addObjectToContainer(containerIndex, object);
          },
          onObjectRemoved: (object) {
            _removeObjectFromContainer(containerIndex, object);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Containers'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              _clearPreferences(); // Chiama la funzione per pulire i dati
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dati eliminati con successo.')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _containers.length,
        itemBuilder: (context, index) {
          final container = _containers[index];
          return ListTile(
            title: Text(
              container.name,
              style: TextStyle(
                color: container.isConnected ? Colors.green : Colors.black,
              ),
            ),
            subtitle: Text(container.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.bluetooth),
                  onPressed: () {
                    // Logica per la connessione Bluetooth manuale
                    _connectToBluetoothDevice(container);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showEditDialog(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeContainer(index),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _showAddObjectDialog(index),
                ),
              ],
            ),
            onTap: () => _navigateToContainerDetails(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContainerDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class ContainerDetailsPage extends StatelessWidget {
  final Container container;
  final List<String> objects;
  final Function(String) onObjectAdded;
  final Function(String) onObjectRemoved;

  ContainerDetailsPage({
    required this.container,
    required this.objects,
    required this.onObjectAdded,
    required this.onObjectRemoved,
  });

  void _showAddObjectDialog(BuildContext context) {
    String? selectedObject;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Object to ${container.name}'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                isExpanded: true,
                value: selectedObject,
                items: objects
                    .map((obj) => DropdownMenuItem<String>(
                          value: obj,
                          child: Text(obj),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedObject = value;
                  });
                },
                hint: Text("Select an object"),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedObject != null) {
                  onObjectAdded(selectedObject!);
                  Navigator.of(context).maybePop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select an object')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveObjectDialog(BuildContext context, String object) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Object from ${container.name}'),
          content: Text('Are you sure you want to remove "$object"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onObjectRemoved(object);
                Navigator.of(context).maybePop();
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${container.name} Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: container.objects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(container.objects[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showRemoveObjectDialog(
                        context, container.objects[index]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showAddObjectDialog(context),
              child: Text('Add Object'),
            ),
          ),
        ],
      ),
    );
  }
}
