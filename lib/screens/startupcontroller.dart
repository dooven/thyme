import 'package:boopplant/blocs/bloc.dart';
import 'package:boopplant/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return StreamBuilder<bool>(
        stream: _startupControllerBloc.isReady,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return TabNavigator(navigatorKey: navigatorKey);
        });
  }
}

class StartupControllerBloc {
  final DatabaseBloc database;
  final NotificationBloc notificationBloc;

  Stream<bool> get isReady => CombineLatestStream(
      [database.databaseStream, notificationBloc.isReadyStream], (_) => true);

  StartupControllerBloc(this.database, this.notificationBloc);
}
