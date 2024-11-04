import 'package:flutter/material.dart';

class MyContainer {
  String name;
  String description;
  List<String> items;

  MyContainer({required this.name, required this.description}) : items = [];
}

class ContainersPage extends StatefulWidget {
  @override
  _ContainersPageState createState() => _ContainersPageState();
}

class _ContainersPageState extends State<ContainersPage> {
  List<MyContainer> _containers = [];

  void _addContainer(String name, String description) {
    setState(() {
      _containers.add(MyContainer(name: name, description: description));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added!')),
      );
    });
  }

  void _editContainer(int index, String name, String description) {
    setState(() {
      _containers[index].name = name;
      _containers[index].description = description;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_containers[index].name} updated!')),
      );
    });
  }

  void _removeContainer(int index) {
    String name = _containers[index].name;
    setState(() {
      _containers.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name removed!')),
    );
  }

  void _scanNFCForContainer() {
    String scannedName = 'Scanned Container';
    String scannedDescription = 'Description for the scanned container';
    _showContainerDialog(scannedName, scannedDescription);
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

  void _addItemToContainer(int index, String item) {
    setState(() {
      _containers[index].items.add(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to ${_containers[index].name}!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Containers'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Torna alla schermata precedente
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showContainerDialog('', ''),
          ),
          IconButton(
            icon: Icon(Icons.nfc),
            onPressed: _scanNFCForContainer,
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
}
