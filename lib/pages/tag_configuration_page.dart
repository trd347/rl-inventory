import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TagConfigurationPage extends StatefulWidget {
  @override
  _TagConfigurationPageState createState() => _TagConfigurationPageState();
}

class _TagConfigurationPageState extends State<TagConfigurationPage> {
  String _tagId = '';
  String _tagName = '';
  String _tagData = '';

  Future<void> _scanTag() async {
    try {
      NFCTag tag = await FlutterNfcKit.poll();
      setState(() {
        _tagId = tag.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tag scanned: $_tagId')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan NFC tag: $e')),
      );
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  Future<void> _saveTagConfiguration() async {
    if (_tagId.isEmpty || _tagName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please scan a tag and enter a name.')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> tagConfig = {
      'id': _tagId,
      'name': _tagName,
      'data': _tagData,
    };
    String encodedTagConfig = json.encode(tagConfig);
    await prefs.setString('tag_$_tagId', encodedTagConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tag configuration saved successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tag Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configure your NFC tags',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanTag,
              child: Text('Scan NFC Tag'),
            ),
            SizedBox(height: 20),
            if (_tagId.isNotEmpty)
              Text('Tag ID: $_tagId',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Tag Name'),
              onChanged: (value) {
                setState(() {
                  _tagName = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Tag Data (Optional)'),
              onChanged: (value) {
                setState(() {
                  _tagData = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTagConfiguration,
              child: Text('Save Configuration'),
            ),
          ],
        ),
      ),
    );
  }
}
