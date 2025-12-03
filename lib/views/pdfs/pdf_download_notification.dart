import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../main.dart';

Future<void> showDownloadNotification(String fileName, String filePath) async {

  // 1. CHECK AND REQUEST PERMISSION (Android 13+)
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        status = await Permission.notification.request();
        if (status.isDenied) {
          return;
        }
      }
    }
  }

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'download_channel',
    'Downloads',
    channelDescription: 'Notifies when a file is downloaded',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  // 3. SHOW NOTIFICATION
  await flutterLocalNotificationsPlugin.show(
    0,
    'Download Complete',
    '$fileName has been saved to Downloads.',
    platformChannelSpecifics,
    payload: filePath,
  );
}