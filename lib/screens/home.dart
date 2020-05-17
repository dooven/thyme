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
  Map<String, Widget> _routeBuilders() {
    return {
      TabNavigatorRoutes.plantList: PlantList(),
      TabNavigatorRoutes.plantInfo: PlantInfo(),
      TabNavigatorRoutes.plantModify: PlantModify(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders();

    return Provider<PlantListBloc>(
      create: (_) => PlantListBloc(
        PlantRepository(database: Provider.of<Database>(context)),
      ),
      child: WillPopScope(
        onWillPop: () async =>
            !await widget.navigatorKey.currentState.maybePop(),
        child: Navigator(
            initialRoute: '/',
            key: widget.navigatorKey,
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(
                builder: (_) => routeBuilders[routeSettings.name],
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
