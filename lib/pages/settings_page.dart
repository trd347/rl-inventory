import 'package:flutter/material.dart';
import 'account_settings_page.dart';
import 'notification_settings_page.dart';
import 'privacy_settings_page.dart';
import 'help_support_page.dart';
import 'about_page.dart';
import 'theme_settings_page.dart'; // Importa la pagina del tema
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsPage extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Function(dynamic, dynamic)
      onThemeChanged; // Modifica il tipo del callback per corrispondere a quello usato in AccountSettingsPage

  SettingsPage({
    required this.flutterLocalNotificationsPlugin,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
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
                    onThemeChanged:
                        onThemeChanged, // Passa il callback coerente
                  ),
                ),
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
                  ),
                ),
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
          ListTile(
            title: Text('Theme Settings'),
            trailing: Icon(Icons.color_lens),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThemeSettingsPage(
                    onThemeChanged:
                        (dynamic primaryColor, dynamic secondaryColor) {
                      // Utilizza il callback passato per aggiornare il tema in tempo reale
                      onThemeChanged(primaryColor, secondaryColor);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
