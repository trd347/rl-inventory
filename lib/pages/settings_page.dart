import 'package:flutter/material.dart';
import 'account_settings_page.dart';
import 'notification_settings_page.dart';
import 'privacy_settings_page.dart';
import 'help_support_page.dart';
import 'about_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsPage extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  SettingsPage({required this.flutterLocalNotificationsPlugin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        // Rimosso il tasto di ritorno
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Account Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AccountSettingsPage(
                          onThemeChanged: (bool) {},
                        )),
              );
            },
          ),
          ListTile(
            title: Text('Notification Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationSettingsPage(
                          flutterLocalNotificationsPlugin:
                              flutterLocalNotificationsPlugin,
                        )),
              );
            },
          ),
          ListTile(
            title: Text('Privacy Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacySettingsPage()),
              );
            },
          ),
          ListTile(
            title: Text('Help & Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpSupportPage()),
              );
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
