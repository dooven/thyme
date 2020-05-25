import 'dart:io';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/repository/schedule.dart';
import 'package:boopplant/screens/home.dart';
import 'package:boopplant/screens/plant_modify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sliver_fab/sliver_fab.dart';
import 'package:sqflite/sqflite.dart';

import 'plant_schedule_list.dart';

class PlantInfoScreenArguments {
  final int id;

  const PlantInfoScreenArguments({this.id});
}

class PlantInfo extends StatefulWidget {
  final int plantId;

  const PlantInfo({Key key, this.plantId}) : super(key: key);

  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo> {
  PlantInfoBloc _plantInfoBloc;
  Stream<bool> _isScreenReady;
  Future initialScheduleFuture;

  @override
  void dispose() {
    _plantInfoBloc.dispose();
    _plantInfoBloc = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final database = Provider.of<Database>(context, listen: false);

    final initialBloc = PlantInfoBloc(
        plantId: widget.plantId,
        plantRepository: PlantRepository(database: database),
        scheduleRepository: ScheduleRepository(database: database));

    if (initialBloc != _plantInfoBloc) {
      _plantInfoBloc = initialBloc;
      _plantInfoBloc.getPlantById();
      _plantInfoBloc.getSchedulesByPlantId();
      _isScreenReady = _plantInfoBloc.isScreenReady;
    }
  }

  Widget plantName(Plant plant) {
    return Text(
      plant.name,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  void editPlant(Plant plant) {
    Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.plantModify,
            arguments: PlantModifyScreenArgument(plantId: plant.id))
        .then((value) {
      if (value) {
        _plantInfoBloc.getPlantById();
      }
    });
  }

  Widget flexibleSpaceBar(Plant plant) {
    return FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          if (plant.imageUrl != null)
            Image.file(
              File(plant.imageUrl),
              fit: BoxFit.cover,
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.0, 1),
                end: Alignment(0.0, 0.0),
                colors: <Color>[
                  Color(0x50000000),
                  Color(0x00000000),
                ],
              ),
            ),
          ),
        ],
      ),
      title: Text(
        plant.name,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  toggleDay(int day) {
    final byweekday = _plantInfoBloc.plant.byweekday;
    List<int> newByWeekDay = [];
    if (byweekday.contains(day)) {
      newByWeekDay = byweekday.where((element) => element != day).toList();
    } else {
      newByWeekDay
        ..addAll(byweekday)
        ..add(day);
    }
  }

  Widget buildAddSchedule() {
    void add() {
      setState(() {
        initialScheduleFuture = _plantInfoBloc.scheduleRepository
            .insert(Schedule(
                byweekday: [],
                name: 'New Schedule',
                timeOfDay: TimeOfDay.now(),
                createdAt: DateTime.now(),
                plantId: widget.plantId))
            .then((_) => _plantInfoBloc.getSchedulesByPlantId());
      });
    }

    return Card(
      child: FutureBuilder(
        future: initialScheduleFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          return InkWell(
            onTap: isLoading ? null : add,
            child: Container(
              margin: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Add a schedule"),
                  isLoading
                      ? CircularProgressIndicator()
                      : Icon(Icons.access_time),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<bool>(
        initialData: false,
        stream: _isScreenReady,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return SliverFab(
            floatingWidget: FloatingActionButton(
              onPressed: () => editPlant(_plantInfoBloc.plant),
              child: Icon(Icons.edit),
            ),
            expandedHeight: 300.0,
            slivers: [
              SliverAppBar(
                iconTheme: IconThemeData(color: Colors.white),
                floating: true,
                expandedHeight: 300.0,
                flexibleSpace: flexibleSpaceBar(_plantInfoBloc.plant),
              ),
              SliverPadding(
                padding: EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 20),
                    if (_plantInfoBloc.schedule.isEmpty) buildAddSchedule(),
                  ]),
                ),
              ),
              ScheduleList(
                schedule: _plantInfoBloc.schedule,
                updateSchedule: _plantInfoBloc.updateSchedule,
              ),
            ],
          );
        },
      ),
    );
  }
}

class PlantInfoBloc {
  final PlantRepository plantRepository;
  final ScheduleRepository scheduleRepository;
  final int plantId;

  final _plantController = BehaviorSubject<Plant>();
  final _scheduleController = BehaviorSubject<List<Schedule>>();

  PlantInfoBloc({this.plantRepository, this.scheduleRepository, this.plantId});

  Stream<Plant> get plantStream => _plantController.stream;

  Stream<List<Schedule>> get scheduleStream => _scheduleController.stream;

  Plant get plant => _plantController.value;

  List<Schedule> get schedule => _scheduleController.value;

  Stream<bool> get isScreenReady =>
      CombineLatestStream([scheduleStream, plantStream], (_) => true);

  Future<void> getPlantById() {
    return plantRepository
        .getById(plantId)
        .then(_plantController.add)
        .catchError((error) => _plantController.addError(
              "Failed to fetch plant. Please try again later",
            ));
  }

  Future<void> getSchedulesByPlantId() {
    return scheduleRepository
        .getByPlantId(plantId)
        .then((value) {
          return value;
        })
        .then(_scheduleController.add)
        .catchError((error) => _plantController.addError(
              "Failed to fetch schedules. Please try again later",
            ));
  }

  Future<void> updateSchedule(int scheduleId,
      {List<int> byweekday, String name}) {
    return scheduleRepository
        .update(scheduleId, byweekday: byweekday, name: name)
        .then((_) => scheduleRepository.getById(scheduleId))
        .then((value) => _scheduleController
            .add(schedule.map((e) => e.id == value.id ? value : e).toList()));
  }

  void dispose() {
    _plantController.close();
    _scheduleController.close();
  }
}
