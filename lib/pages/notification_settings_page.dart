import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:typed_data';

class NotificationSettingsPage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationSettingsPage({required this.flutterLocalNotificationsPlugin});

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  bool _emailAlerts = true;
  bool _dailySummary = false;
  bool _weeklySummary = false;
  bool _muteNotifications = false;
  String _notificationTone = 'Default';

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? false;
      _emailAlerts = prefs.getBool('emailAlerts') ?? true;
      _dailySummary = prefs.getBool('dailySummary') ?? false;
      _weeklySummary = prefs.getBool('weeklySummary') ?? false;
      _muteNotifications = prefs.getBool('muteNotifications') ?? false;
      _notificationTone = prefs.getString('notificationTone') ?? 'Default';
    });
    _scheduleSummaryNotifications(); // Aggiorna i sommari in base alle impostazioni
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setBool('emailAlerts', _emailAlerts);
    await prefs.setBool('dailySummary', _dailySummary);
    await prefs.setBool('weeklySummary', _weeklySummary);
    await prefs.setBool('muteNotifications', _muteNotifications);
    await prefs.setString('notificationTone', _notificationTone);

    _scheduleSummaryNotifications(); // Programma o annulla i sommari in base alle nuove impostazioni
  }

  Future<void> _sendNotification(String title, String body) async {
    if (!_notificationsEnabled || _muteNotifications) return;

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      playSound: _soundEnabled,
      enableVibration: _vibrationEnabled,
      vibrationPattern:
          _vibrationEnabled ? Int64List.fromList([0, 1000, 500, 1000]) : null,
      sound: _notificationTone == 'Silent'
          ? null
          : RawResourceAndroidNotificationSound(
              _notificationTone.toLowerCase()),
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await widget.flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: 'item x',
    );
  }

  Future<void> _scheduleSummaryNotifications() async {
    await widget.flutterLocalNotificationsPlugin
        .cancelAll(); // Annulla notifiche esistenti
    if (_notificationsEnabled) {
      if (_dailySummary) {
        await widget.flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Daily Summary',
          'Your daily summary of activities.',
          _getDailyTime(),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'summary_channel_id',
              'Summary Channel',
              channelDescription: 'Summary Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
      if (_weeklySummary) {
        await widget.flutterLocalNotificationsPlugin.zonedSchedule(
          1,
          'Weekly Summary',
          'Your weekly summary of activities.',
          _getWeeklyTime(),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'summary_channel_id',
              'Summary Channel',
              channelDescription: 'Summary Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  tz.TZDateTime _getDailyTime() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 8, 0); // 8 AM daily
  }

  tz.TZDateTime _getWeeklyTime() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final int weekday = DateTime.monday;
    return tz.TZDateTime(
        tz.local, now.year, now.month, now.day + (weekday - now.weekday), 8, 0);
  }

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
                  if (!value) _muteNotifications = true;
                });
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: Text('Sound Notifications'),
              value: _soundEnabled,
              onChanged: _notificationsEnabled
                  ? (bool value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                      _saveSettings();
                    }
                  : null,
            ),
            SwitchListTile(
              title: Text('Vibrate on Notifications'),
              value: _vibrationEnabled,
              onChanged: _notificationsEnabled
                  ? (bool value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                      _saveSettings();
                    }
                  : null,
            ),
            SwitchListTile(
              title: Text('Email Alerts'),
              value: _emailAlerts,
              onChanged: (bool value) {
                setState(() {
                  _emailAlerts = value;
                });
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: Text('Daily Summary Notifications'),
              value: _dailySummary,
              onChanged: (bool value) {
                setState(() {
                  _dailySummary = value;
                });
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: Text('Weekly Summary Notifications'),
              value: _weeklySummary,
              onChanged: (bool value) {
                setState(() {
                  _weeklySummary = value;
                });
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: Text('Mute Notifications'),
              value: _muteNotifications,
              onChanged: _notificationsEnabled
                  ? (bool value) {
                      setState(() {
                        _muteNotifications = value;
                      });
                      _saveSettings();
                    }
                  : null,
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
              onChanged: _notificationsEnabled
                  ? (String? newValue) {
                      setState(() {
                        _notificationTone = newValue!;
                      });
                      _saveSettings();
                    }
                  : null,
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings saved successfully')),
                );
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
