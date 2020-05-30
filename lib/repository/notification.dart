import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationRepository {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationRepository(this._flutterLocalNotificationsPlugin);

  Future<void> periodicallyShow(
      int id, String title, String body, RepeatInterval repeatInterval) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'weekly-notification',
        'Plants Weekly Notification',
        'Plants Weekly Notification',
        importance: Importance.Default,
        priority: Priority.Default);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    return _flutterLocalNotificationsPlugin.periodicallyShow(
        id, title, body, repeatInterval, platformChannelSpecifics);
  }

  Future<void> cancel(int id) {
    return _flutterLocalNotificationsPlugin.cancel(id);
  }
}
