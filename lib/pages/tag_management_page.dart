import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TagManagementPage extends StatefulWidget {
  @override
  _TagManagementPageState createState() => _TagManagementPageState();
}

class _TagManagementPageState extends State<TagManagementPage> {
  List<Map<String, dynamic>> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tagsJson = prefs.getString('tags');
    if (tagsJson != null) {
      setState(() {
        _tags = List<Map<String, dynamic>>.from(json.decode(tagsJson));
      });
    }
  }

  Future<void> _saveTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tags', json.encode(_tags));
  }

  Future<void> _addNewTag() async {
    try {
      NFCTag tag = await FlutterNfcKit.poll();
      String tagId = tag.id;

      TextEditingController nameController = TextEditingController();
      TextEditingController descriptionController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Configure New Tag'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Tag Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Tag Description'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tags.add({
                      'id': tagId,
                      'name': nameController.text,
                      'description': descriptionController.text,
                    });
                  });
                  _saveTags();
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan NFC tag: $e')),
      );
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  void _editTag(int index) {
    TextEditingController nameController =
        TextEditingController(text: _tags[index]['name']);
    TextEditingController descriptionController =
        TextEditingController(text: _tags[index]['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tag Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Tag Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tags[index]['name'] = nameController.text;
                  _tags[index]['description'] = descriptionController.text;
                });
                _saveTags();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTag(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Tag'),
          content: Text('Are you sure you want to delete this tag?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tags.removeAt(index);
                });
                _saveTags();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tag Management')),
      body: ListView.builder(
        itemCount: _tags.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_tags[index]['name'] ?? 'Unknown Tag'),
            subtitle: Text(_tags[index]['description'] ?? ''),
            onTap: () => _editTag(index),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteTag(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTag,
        child: Icon(Icons.add),
      ),
    );
  }
}
