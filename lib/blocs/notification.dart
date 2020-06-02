import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationBloc {
  final _isReadyController = BehaviorSubject<bool>();
  final _notificationMessage = BehaviorSubject<String>();

  Stream<bool> get isReadyStream => _isReadyController.stream;

  Stream<String> get notificationMessageStream => _notificationMessage.stream;

  bool get isReady => _isReadyController.value;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationBloc() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future selectNotification(String payload) async {
    _notificationMessage.add(payload);
  }

  Future<void> initializePlugin() {
    final initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );
    final initializationSettingsIOS = IOSInitializationSettings(
      // ignore: missing_return
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    return flutterLocalNotificationsPlugin
        .initialize(
          initializationSettings,
          onSelectNotification: selectNotification,
        )
        .then(_isReadyController.add);
  }

  void dispose() {
    _isReadyController.close();
  }
}
