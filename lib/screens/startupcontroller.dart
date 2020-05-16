import 'package:boopplant/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

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

    _startupControllerBloc =
        StartupControllerBloc(Provider.of<Database>(context));
  }

  @override
  Widget build(BuildContext context) {
    if (!_startupControllerBloc.isReady) {
      return CircularProgressIndicator();
    }

    return TabNavigator(navigatorKey: navigatorKey);
  }
}

class StartupControllerBloc {
  final Database database;

  get isReady => database != null;

  StartupControllerBloc(this.database);
}
