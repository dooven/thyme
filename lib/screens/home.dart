import 'dart:async';

import 'package:boopplant/blocs/notification.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/repository/schedule.dart';
import 'package:boopplant/screens/day_schedule_list.dart';
import 'package:boopplant/screens/home_tab.dart';
import 'package:boopplant/screens/plant_schedule_list.dart';
import 'package:boopplant/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class HomeRoutes {
  static const String scheduleList = '/';
  static const String plantList = '/plant/list';
  static const String plantInfo = '/plant/info';
  static const String plantModify = '/plant/modify';
}

class Home extends StatefulWidget {
  Home({this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, Widget> routeBuilders;
  NotificationBloc notificationBloc;
  StreamSubscription notificationSub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _notificationBloc = context.read<NotificationBloc>();

    if (notificationBloc != _notificationBloc) {
      notificationSub?.cancel();
      notificationBloc = _notificationBloc;
      notificationSub =
          notificationBloc.notificationMessageStream.listen((event) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          widget.navigatorKey.currentState.pushNamed('/plant/info',
              arguments: PlantInfoScreenArguments(id: 1));
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    notificationBloc?.dispose();
    notificationSub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final plantRepository = PlantRepository(database: database);
    final scheduleRepository = ScheduleRepository(database: database);
    return MultiProvider(
      providers: [
        Provider<PlantListBloc>(
          create: (_) => PlantListBloc(plantRepository),
          dispose: (context, value) => value.dispose(),
        ),
        Provider<DayScheduleListBloc>(
          create: (_) =>
              DayScheduleListBloc(scheduleRepository, plantRepository),
          dispose: (context, value) => value.dispose(),
        )
      ],
      child: WillPopScope(
        onWillPop: () async =>
            !await widget.navigatorKey.currentState.maybePop(),
        child: Navigator(
            key: widget.navigatorKey,
            observers: [HeroController()],
            onGenerateRoute: (routeSettings) {
              Widget widget;
              switch (routeSettings.name) {
                case HomeRoutes.scheduleList:
                case HomeRoutes.plantList:
                  widget = HomeTab();
                  break;
                case HomeRoutes.plantInfo:
                  final PlantInfoScreenArguments screenArguments =
                      routeSettings.arguments;
                  widget = PlantInfo(plantId: screenArguments.id);
                  break;
                case HomeRoutes.plantModify:
                  widget = PlantModify();
                  break;
              }

              return MaterialPageRoute(
                builder: (_) => widget,
                settings: routeSettings,
              );
            }),
      ),
    );
  }
}
