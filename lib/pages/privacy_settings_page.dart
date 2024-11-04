import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  @override
  _PrivacySettingsPageState createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _profilePrivate = false; // Valore di esempio
  bool _shareDataWithThirdParties = false; // Valore di esempio

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Make Profile Private'),
              value: _profilePrivate,
              onChanged: (bool value) {
                setState(() {
                  _profilePrivate = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Share Data with Third Parties'),
              value: _shareDataWithThirdParties,
              onChanged: (bool value) {
                setState(() {
                  _shareDataWithThirdParties = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Funzione per salvare le impostazioni
                print('Profile Private: $_profilePrivate');
                print(
                    'Share Data with Third Parties: $_shareDataWithThirdParties');
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
