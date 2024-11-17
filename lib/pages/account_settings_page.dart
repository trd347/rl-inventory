import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class AccountSettingsPage extends StatefulWidget {
  final Function(dynamic primary, dynamic secondary) onThemeChanged;

  AccountSettingsPage({required this.onThemeChanged});

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _profilePictureUrlController =
      TextEditingController();

  bool _isPublicProfile = true;
  String _language = 'English';
  bool _twoFactorAuth = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _showOnlineStatus = true;
  bool _saveLoginInfo = false;
  bool _useBiometricAuth = false;

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Carica le impostazioni salvate
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = prefs.getString('firstName') ?? '';
      _lastNameController.text = prefs.getString('lastName') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _bioController.text = prefs.getString('bio') ?? '';
      _profilePictureUrlController.text =
          prefs.getString('profilePictureUrl') ?? '';
      _language = prefs.getString('language') ?? 'English';
      _twoFactorAuth = prefs.getBool('twoFactorAuth') ?? false;
      _emailNotifications = prefs.getBool('emailNotifications') ?? true;
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _showOnlineStatus = prefs.getBool('showOnlineStatus') ?? true;
      _saveLoginInfo = prefs.getBool('saveLoginInfo') ?? false;
      _useBiometricAuth = prefs.getBool('useBiometricAuth') ?? false;
    });
  }

  // Salva le impostazioni
  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', _firstNameController.text);
    await prefs.setString('lastName', _lastNameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('bio', _bioController.text);
    await prefs.setString(
        'profilePictureUrl', _profilePictureUrlController.text);
    await prefs.setString('language', _language);
    await prefs.setBool('twoFactorAuth', _twoFactorAuth);
    await prefs.setBool('emailNotifications', _emailNotifications);
    await prefs.setBool('pushNotifications', _pushNotifications);
    await prefs.setBool('showOnlineStatus', _showOnlineStatus);
    await prefs.setBool('saveLoginInfo', _saveLoginInfo);
    await prefs.setBool('useBiometricAuth', _useBiometricAuth);
    Navigator.pop(context); // Torna alla pagina precedente dopo il salvataggio
  }

  // Mostra un dialogo di conferma per il logout
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conferma Logout'),
          content: Text('Sei sicuro di voler effettuare il logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi il dialogo
              },
            ),
            TextButton(
              child: Text('Sì'),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
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
            onPressed: _saveSettings, // Salva e torna alla pagina precedente
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Cognome'),
              ),
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
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Bio'),
              ),
              TextField(
                controller: _profilePictureUrlController,
                decoration: InputDecoration(labelText: 'Sito web'),
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
                title: Text('Use Biometric Authentication'),
                value: _useBiometricAuth,
                onChanged: (bool value) async {
                  bool canCheckBiometrics = await auth.canCheckBiometrics;
                  if (canCheckBiometrics) {
                    setState(() {
                      _useBiometricAuth = value;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Biometric authentication not available'),
                      ),
                    );
                  }
                },
              ),
              ElevatedButton(
                onPressed: _showLogoutConfirmation,
                child: Text('Log Out'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/theme-settings');
                },
                child: Text('Theme Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
