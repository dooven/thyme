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
    if (plantMap.isEmpty) {
      return [];
    }
    final sortedKey = scheduleMap.keys.toList()..sort();

    return sortedKey.expand((element) {
      return [
        ListTile(
          title: Text(
            TimeOfDay(hour: element, minute: 0).format(context),
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
            subtitle: Text(schedule.name),
            trailing: Text(timeOfDay.format(context)),
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

        return Column(
          children: [
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Today's Schedule",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.black54))
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    return listWidgets[index];
                  },
                  itemCount: listWidgets.length),
            ),
          ],
        );
      },
    );
  }
}

class DayScheduleListBloc {
  final _scheduleController = BehaviorSubject<List<Schedule>>.seeded([]);
  final _plantsController = BehaviorSubject<List<Plant>>.seeded([]);
  final _fetchController = BehaviorSubject<bool>.seeded(true);

  Stream<bool> globalRefreshStream;

  final ScheduleRepository _scheduleRepository;
  final PlantRepository _plantRepository;

  Sink<bool> get fetchControllerSink => _fetchController.sink;
  Stream<bool> get fetchStream => _fetchController.stream;
  Stream<List<Schedule>> get scheduleStream => _scheduleController.stream;
  Stream<bool> get fetchStreamWithGlobal => Rx.combineLatest2(
        fetchStream,
        globalRefreshStream,
        (_, __) => true,
      ).startWith(true);
  Stream<void> get scheduleListFetcher =>
      fetchStreamWithGlobal.asyncMap((event) => this
          ._scheduleRepository
          .getByDay(DateTime.now().weekday % 7)
          .then(_scheduleController.add));

  Map<int, List<Schedule>> get scheduleByTime => groupBy(
        _scheduleController.value,
        (Schedule element) => element.timeOfDay.hour,
      );
  Map<int, Plant> get plantById =>
      {for (final v in _plantsController.value) v.id: v};

  Stream<void> get plantListFetcher => Rx.combineLatest2(
      fetchStreamWithGlobal,
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
