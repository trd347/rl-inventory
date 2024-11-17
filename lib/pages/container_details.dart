import 'package:flutter/material.dart';
import 'package:rl_inventory/bluetooth_manager.dart';
import 'package:rl_inventory/pages/containers_page.dart' as inv;

class ContainerDetailsPage extends StatefulWidget {
  final inv.Container container;
  final List<String> objects;
  final Function(String) onObjectAdded;
  final Function(String) onObjectRemoved;
  final Function onContainerUpdated;

  ContainerDetailsPage({
    required this.container,
    required this.objects,
    required this.onObjectAdded,
    required this.onObjectRemoved,
    required this.onContainerUpdated,
  });

  @override
  _ContainerDetailsPageState createState() => _ContainerDetailsPageState();
}

class _ContainerDetailsPageState extends State<ContainerDetailsPage> {
  String? selectedObject;

  @override
  void initState() {
    super.initState();
  }

  void _showAddObjectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Object to ${widget.container.name}'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                isExpanded: true,
                value: selectedObject,
                items: widget.objects
                    .where((obj) => !widget.container.objects.contains(obj))
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
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedObject != null) {
                  setState(() {
                    widget.onObjectAdded(selectedObject!);
                    widget.container.objects.add(selectedObject!);
                    widget.onContainerUpdated();
                  });
                  Navigator.of(context).pop();
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

  void _showRemoveObjectDialog(String object) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Object from ${widget.container.name}'),
          content: Text('Are you sure you want to remove "$object"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.onObjectRemoved(object);
                  widget.container.objects.remove(object);
                  widget.onContainerUpdated();
                });
                Navigator.of(context).pop();
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
        title: Text('${widget.container.name} Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.container.objects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.container.objects[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showRemoveObjectDialog(
                        widget.container.objects[index]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showAddObjectDialog,
              child: Text('Add Object'),
            ),
          ),
        ],
      ),
    );
  }
}
