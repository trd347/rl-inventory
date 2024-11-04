import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPublicProfile = true;
  String _username = '';
  String _bio = '';
  String _profilePictureUrl = '';
  String _language = 'English';
  bool _twoFactorAuth = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _showOnlineStatus = true;
  bool _saveLoginInfo = false;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Carica le impostazioni salvate
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _username = prefs.getString('username') ?? '';
      _bio = prefs.getString('bio') ?? '';
      _profilePictureUrl = prefs.getString('profilePictureUrl') ?? '';
      _language = prefs.getString('language') ?? 'English';
      _twoFactorAuth = prefs.getBool('twoFactorAuth') ?? false;
      _emailNotifications = prefs.getBool('emailNotifications') ?? true;
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _showOnlineStatus = prefs.getBool('showOnlineStatus') ?? true;
      _saveLoginInfo = prefs.getBool('saveLoginInfo') ?? false;
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  // Salva le impostazioni
  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', _emailController.text);
    prefs.setString('username', _username);
    prefs.setString('bio', _bio);
    prefs.setString('profilePictureUrl', _profilePictureUrl);
    prefs.setString('language', _language);
    prefs.setBool('twoFactorAuth', _twoFactorAuth);
    prefs.setBool('emailNotifications', _emailNotifications);
    prefs.setBool('pushNotifications', _pushNotifications);
    prefs.setBool('showOnlineStatus', _showOnlineStatus);
    prefs.setBool('saveLoginInfo', _saveLoginInfo);
    prefs.setBool('darkMode', _darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Torna alla pagina precedente
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveSettings();
              Navigator.pop(context); // Torna alla pagina precedente
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Username'),
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Bio'),
              onChanged: (value) {
                setState(() {
                  _bio = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Profile Picture URL'),
              onChanged: (value) {
                setState(() {
                  _profilePictureUrl = value;
                });
              },
            ),
            DropdownButton<String>(
              value: _language,
              items: <String>['English', 'Italian', 'Spanish', 'French']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _language = newValue!;
                });
              },
              hint: Text('Select Language'),
            ),
            SwitchListTile(
              title: Text('Enable Two-Factor Authentication'),
              value: _twoFactorAuth,
              onChanged: (bool value) {
                setState(() {
                  _twoFactorAuth = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Email Notifications'),
              value: _emailNotifications,
              onChanged: (bool value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Push Notifications'),
              value: _pushNotifications,
              onChanged: (bool value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Online Status'),
              value: _showOnlineStatus,
              onChanged: (bool value) {
                setState(() {
                  _showOnlineStatus = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Save Login Information'),
              value: _saveLoginInfo,
              onChanged: (bool value) {
                setState(() {
                  _saveLoginInfo = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
