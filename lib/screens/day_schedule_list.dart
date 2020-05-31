import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/repository/schedule.dart';
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
        for (var schedule in scheduleMap[element])
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.greenAccent,
            ),
            title: Text(plantMap[schedule.plantId].name),
            trailing: Text(
              "${schedule.timeOfDay.hour}:${schedule.timeOfDay.minute}",
            ),
          )
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
  final _scheduleFetch = BehaviorSubject<bool>.seeded(true);
  final _plantListFetch = BehaviorSubject<bool>.seeded(true);

  final ScheduleRepository _scheduleRepository;
  final PlantRepository _plantRepository;

  Sink<bool> get scheduleFetchSink => _scheduleFetch.sink;
  Stream<bool> get scheduleFetchStream => _scheduleFetch.stream;
  Stream<bool> get plantFetchStream => _plantListFetch.stream;
  Stream<List<Schedule>> get scheduleStream => _scheduleController.stream;
  Map<int, List<Schedule>> get scheduleByTime => groupBy(
        _scheduleController.value,
        (Schedule element) => element.timeOfDay.hour,
      );
  Map<int, Plant> get plantById =>
      {for (final v in _plantsController.value) v.id: v};

  Stream<void> get scheduleListFetcher =>
      scheduleFetchStream.asyncMap((event) => this
          ._scheduleRepository
          .getByDay(DateTime.now().weekday - 1)
          .then(_scheduleController.add));

  Stream<void> get plantListFetcher => Rx.combineLatest2(
      plantFetchStream,
      scheduleStream,
      (_, List<Schedule> schedules) =>
          schedules.map((s) => s.plantId).toList()).asyncMap(
      (ids) => this._plantRepository.getByIds(ids).then(_plantsController.add));

  Stream<bool> get isReady =>
      CombineLatestStream([scheduleListFetcher, plantListFetcher], (_) => true);

  DayScheduleListBloc(this._scheduleRepository, this._plantRepository);

  void dispose() {
    _scheduleController.close();
    _scheduleFetch.close();
    _plantsController.close();
    _plantListFetch.close();
  }
}
