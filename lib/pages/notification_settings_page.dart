import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = true; // Valore di esempio
  bool _soundEnabled = true; // Valore di esempio
  bool _vibrationEnabled = false; // Valore di esempio
  bool _emailAlerts = true; // Notifiche via email
  bool _dailySummary = false; // Sommario giornaliero
  bool _weeklySummary = false; // Sommario settimanale
  bool _muteNotifications = false; // Disattivare notifiche
  String _notificationTone = 'Default'; // Tono di notifica predefinito

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Sound Notifications'),
              value: _soundEnabled,
              onChanged: (bool value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Vibrate on Notifications'),
              value: _vibrationEnabled,
              onChanged: (bool value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Email Alerts'),
              value: _emailAlerts,
              onChanged: (bool value) {
                setState(() {
                  _emailAlerts = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Daily Summary Notifications'),
              value: _dailySummary,
              onChanged: (bool value) {
                setState(() {
                  _dailySummary = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Weekly Summary Notifications'),
              value: _weeklySummary,
              onChanged: (bool value) {
                setState(() {
                  _weeklySummary = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Mute Notifications'),
              value: _muteNotifications,
              onChanged: (bool value) {
                setState(() {
                  _muteNotifications = value;
                });
              },
            ),
            DropdownButton<String>(
              value: _notificationTone,
              items: <String>['Default', 'Tone 1', 'Tone 2', 'Silent']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _notificationTone = newValue!;
                });
              },
              hint: Text('Select Notification Tone'),
            ),
            ElevatedButton(
              onPressed: () {
                // Funzione per salvare le impostazioni
                print('Notifications Enabled: $_notificationsEnabled');
                print('Sound Enabled: $_soundEnabled');
                print('Vibration Enabled: $_vibrationEnabled');
                print('Email Alerts: $_emailAlerts');
                print('Daily Summary: $_dailySummary');
                print('Weekly Summary: $_weeklySummary');
                print('Mute Notifications: $_muteNotifications');
                print('Notification Tone: $_notificationTone');
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
