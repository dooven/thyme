import 'dart:async';

import 'package:boopplant/blocs/notification.dart';
import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class TabNavigatorRoutes {
  static const String plantList = '/';
  static const String plantInfo = '/plant/info';
  static const String plantModify = '/plant/modify';
}

class TabNavigator extends StatefulWidget {
  TabNavigator({this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
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
    return Provider<PlantListBloc>(
      create: (_) => PlantListBloc(
        PlantRepository(database: Provider.of<Database>(context)),
      ),
      dispose: (context, value) => value.dispose(),
      child: WillPopScope(
        onWillPop: () async =>
            !await widget.navigatorKey.currentState.maybePop(),
        child: Navigator(
            key: widget.navigatorKey,
            observers: [
              HeroController(),
            ],
            onGenerateRoute: (routeSettings) {
              Widget widget;
              switch (routeSettings.name) {
                case TabNavigatorRoutes.plantList:
                  widget = PlantList();
                  break;
                case TabNavigatorRoutes.plantInfo:
                  final PlantInfoScreenArguments screenArguments =
                      routeSettings.arguments;
                  widget = PlantInfo(plantId: screenArguments.id);
                  break;
                case TabNavigatorRoutes.plantModify:
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

class PlantListBloc {
  final _allPlantsFetchController = BehaviorSubject<bool>();
  final _singlePlantFetchController = BehaviorSubject<int>();
  final _plantListController = BehaviorSubject<List<Plant>>();

  final PlantRepository _plantRepository;

  Stream<bool> get plantListFetchStream => _allPlantsFetchController.stream;

  Function(bool) get plantListFetchSink => _allPlantsFetchController.sink.add;

  Stream<void> get plantListFetcher => plantListFetchStream
      .asyncMap((event) => this._plantRepository.list())
      .doOnData(_plantListController.add);

  List<Plant> get plantList => _plantListController.value;

  PlantListBloc(this._plantRepository);

  void dispose() {
    _allPlantsFetchController.close();
    _plantListController.close();
    _singlePlantFetchController.close();
  }
}
