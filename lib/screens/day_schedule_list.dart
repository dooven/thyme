import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/repository/schedule.dart';
import 'package:boopplant/screens/home.dart';
import 'package:boopplant/screens/plant_info.dart';
import 'package:boopplant/widgets/plant_circle_avatar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class DayScheduleList extends StatelessWidget {
  List<Widget> buildList(BuildContext context,
      Map<int, List<Schedule>> scheduleMap, Map<int, Plant> plantMap) {
    final sortedKey = scheduleMap.keys.toList()..sort();

    return sortedKey.expand((element) {
      return [
        ListTile(
          title: Text(
            "$element:00",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ...scheduleMap[element].map((schedule) {
          final plantItem = plantMap[schedule.plantId];
          final timeOfDay = schedule.timeOfDay;

          return ListTile(
            leading: PlantCircleAvatar(
              imageUrl: plantItem.imageUrl,
            ),
            title: Text(plantItem.name),
            trailing: Text("${timeOfDay.hour}:${timeOfDay.minute}"),
            onTap: () {
              Navigator.of(context).pushNamed(HomeRoutes.plantInfo,
                  arguments: PlantInfoScreenArguments(id: plantItem.id));
            },
          );
        }),
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dayScheduleBloc = context.watch<DayScheduleListBloc>();
    return StreamBuilder(
      stream: dayScheduleBloc.isReady,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final listWidgets = buildList(
            context, dayScheduleBloc.scheduleByTime, dayScheduleBloc.plantById);

        return ListView.builder(
            itemBuilder: (context, index) {
              return listWidgets[index];
            },
            itemCount: listWidgets.length);
      },
    );
  }
}

class DayScheduleListBloc {
  final _scheduleController = BehaviorSubject<List<Schedule>>();
  final _plantsController = BehaviorSubject<List<Plant>>();
  final _fetchController = BehaviorSubject<bool>.seeded(true);

  final ScheduleRepository _scheduleRepository;
  final PlantRepository _plantRepository;

  Sink<bool> get fetchControllerSink => _fetchController.sink;
  Stream<bool> get fetchStream => _fetchController.stream;
  Stream<List<Schedule>> get scheduleStream => _scheduleController.stream;
  Map<int, List<Schedule>> get scheduleByTime => groupBy(
        _scheduleController.value,
        (Schedule element) => element.timeOfDay.hour,
      );
  Map<int, Plant> get plantById =>
      {for (final v in _plantsController.value) v.id: v};

  Stream<void> get scheduleListFetcher => fetchStream.asyncMap((event) => this
      ._scheduleRepository
      .getByDay(DateTime.now().weekday - 1)
      .then(_scheduleController.add));

  Stream<void> get plantListFetcher => Rx.combineLatest2(
      fetchStream,
      scheduleStream,
      (_, List<Schedule> schedules) =>
          schedules.map((s) => s.plantId).toList()).asyncMap(
      (ids) => this._plantRepository.getByIds(ids).then(_plantsController.add));

  Stream<bool> get isReady =>
      CombineLatestStream([scheduleListFetcher, plantListFetcher], (_) => true);

  DayScheduleListBloc(this._scheduleRepository, this._plantRepository);

  void dispose() {
    _scheduleController.close();
    _fetchController.close();
    _plantsController.close();
  }
}
