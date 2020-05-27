import 'package:boopplant/blocs/bloc.dart';
import 'package:boopplant/navigation.dart';
import 'package:boopplant/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class StartupController extends StatefulWidget {
  @override
  _StartupControllerState createState() => _StartupControllerState();
}

class _StartupControllerState extends State<StartupController> {
  StartupControllerBloc _startupControllerBloc;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _startupControllerBloc = StartupControllerBloc(
      context.read<DatabaseBloc>(),
      context.read<NotificationBloc>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<bool>(
          stream: _startupControllerBloc.isReady,
          initialData: false,
          builder: (context, snapshot) {
            Widget renderer;
            if (!snapshot.data) {
              renderer = Center(
                child: Container(
                  height: 100,
                  width: 100,
                  child: Image(image: AssetImage('assets/images/app_icon.png')),
                ),
              );
            } else {
              renderer = TabNavigator(
                navigatorKey: homeScreenNavigationKey,
              );
            }

            return AnimatedSwitcher(
              duration: Duration(seconds: 1),
              child: ProxyProvider<NotificationBloc,
                  FlutterLocalNotificationsPlugin>(
                update: (_, notificationBloc, __) =>
                    notificationBloc.flutterLocalNotificationsPlugin,
                child: renderer,
              ),
            );
          }),
    );
  }
}

class StartupControllerBloc {
  final DatabaseBloc database;
  final NotificationBloc notificationBloc;

  Stream<bool> get isReady => CombineLatestStream(
      [database.databaseStream, notificationBloc.isReadyStream],
      (_) => true).delay(Duration(seconds: 1));

  StartupControllerBloc(this.database, this.notificationBloc);
}
