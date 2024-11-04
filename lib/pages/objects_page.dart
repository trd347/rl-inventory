import 'package:flutter/material.dart';

class Object {
  String name;
  String description;

  Object({required this.name, required this.description});
}

class ObjectsPage extends StatefulWidget {
  @override
  _ObjectsPageState createState() => _ObjectsPageState();
}

class _ObjectsPageState extends State<ObjectsPage> {
  List<Object> _objects = [];

  void _addObject(String name, String description) {
    setState(() {
      _objects.add(Object(name: name, description: description));
    });
  }

  void _editObject(int index, String name, String description) {
    setState(() {
      _objects[index].name = name;
      _objects[index].description = description;
    });
  }

  void _removeObject(int index) {
    setState(() {
      _objects.removeAt(index);
    });
  }

  void _scanNFC() {
    // Logica per la scansione NFC
    String scannedName = 'Scanned Object'; // Nome di esempio dopo la scansione
    String scannedDescription =
        'Description for the scanned object'; // Descrizione di esempio

    showDialog(
      context: context,
      builder: (context) {
        String name = scannedName;
        String description = scannedDescription;

        return AlertDialog(
          title: Text('Add Object'),
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
                _addObject(name, description);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Objects'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _scanNFC, // Attiva la scansione NFC
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
            onTap: () {
              // Eventuale logica quando si tocca un oggetto
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop(); // Torna alla schermata precedente
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }
}
