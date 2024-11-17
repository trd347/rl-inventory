import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NFCManager {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NFCManager({required this.flutterLocalNotificationsPlugin});

  Future<NFCTag?> scanNFC(BuildContext context) async {
    try {
      // Show scanning dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Scanning for NFC tags..."),
              ],
            ),
          );
        },
      );

      // Start NFC polling
      NFCTag tag = await FlutterNfcKit.poll();

      Navigator.of(context).pop(); // Close scanning dialog

      // Show success notification
      await _showNotification(
          'NFC Tag Scanned', 'Tag ID: ${tag.id} scanned successfully.');

      return tag;
    } catch (e) {
      Navigator.of(context).pop(); // Close scanning dialog in case of error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NFC scanning failed: $e')),
      );
      return null;
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  Future<void> finishNFC() async {
    await FlutterNfcKit.finish();
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'nfc_channel_id',
      'NFC Channel',
      channelDescription: 'Channel for NFC notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'nfc_scan',
    );
  }
}

// Usage example:
// NFCManager nfcManager = NFCManager(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
// NFCTag? tag = await nfcManager.scanNFC(context);
// if (tag != null) {
//   // Handle the scanned tag
// }
