import 'dart:io';

import 'package:boopplant/app_colors.dart';
import 'package:boopplant/days.dart';
import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/screens/home.dart';
import 'package:boopplant/screens/plant_modify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sliver_fab/sliver_fab.dart';
import 'package:sqflite/sqflite.dart';

class PlantInfoScreenArguments {
  final int id;

  PlantInfoScreenArguments({this.id});
}

class PlantInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PlantInfoScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;
    return PlantInfo(
      plantId: screenArguments.id,
    );
  }
}

class PlantInfo extends StatefulWidget {
  final plantId;

  const PlantInfo({Key key, this.plantId}) : super(key: key);

  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo> {
  PlantInfoBloc _plantInfoBloc;
  Future plantUpdateFuture;

  @override
  void dispose() {
    _plantInfoBloc.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final initialBloc = PlantInfoBloc(
      plantId: widget.plantId,
      plantRepository:
          PlantRepository(database: Provider.of<Database>(context)),
    );

    if (initialBloc != _plantInfoBloc) {
      _plantInfoBloc = initialBloc;
      _plantInfoBloc.getPlantById();
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

  Widget dayList() {
    return Row(
        children: List.generate(
      7,
      (index) {
        final byweekday = _plantInfoBloc.plant.byweekday;
        final isScheduledForCurrentDay = byweekday.contains(index);
        var dayTextStyle = Theme.of(context).textTheme.bodyText1;

        if (!isScheduledForCurrentDay) {
          dayTextStyle = dayTextStyle.copyWith(color: AppColors.disabledText);
        }

        return Container(
          margin: EdgeInsets.only(right: 8, top: 16),
          child: ClipOval(
            child: Material(
              color: isScheduledForCurrentDay
                  ? Theme.of(context).primaryColor
                  : AppColors.disabledBackground,
              child: InkWell(
                onTap: () => toggleDay(index),
                splashColor: Colors.white,
                child: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Text(
                      Days.dayNumberToLetter(index),
                      style: dayTextStyle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

  modifyScheduleTime() async {
    final selectedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (selectedTime == null) return;

    setState(() {
      plantUpdateFuture = _plantInfoBloc.plantRepository
          .update(widget.plantId, timeOfDay: selectedTime)
          .then((_) => _plantInfoBloc.getPlantById());
    });
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

    setState(() {
      plantUpdateFuture = _plantInfoBloc.plantRepository
          .update(widget.plantId, byweekday: newByWeekDay)
          .then((_) => _plantInfoBloc.getPlantById());
    });
  }

  Widget addSchedule() {
    return FutureBuilder(
      future: plantUpdateFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        return InkWell(
          onTap: isLoading ? null : modifyScheduleTime,
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
    );
  }

  Widget modifySchedule() {
    final timeOfDay = _plantInfoBloc.plant.timeOfDay;
    return Container(
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeOfDay.format(context),
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.black),
              ),
              IconButton(
                color: Theme.of(context).accentColor,
                icon: Icon(Icons.access_time),
                onPressed: modifyScheduleTime,
              )
            ],
          ),
          dayList(),
        ],
      ),
    );
  }

  Widget scheduleCard(Plant plant) {
    return Builder(
      builder: (_) => Card(
        child: plant.timeOfDay == null ? addSchedule() : modifySchedule(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Plant>(
        stream: _plantInfoBloc.plantStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return SliverFab(
            floatingWidget: FloatingActionButton(
              onPressed: () => editPlant(snapshot.data),
              child: Icon(Icons.edit),
            ),
            expandedHeight: 300.0,
            slivers: [
              SliverAppBar(
                iconTheme: IconThemeData(color: Colors.white),
                floating: true,
                expandedHeight: 300.0,
                flexibleSpace: flexibleSpaceBar(snapshot.data),
              ),
              SliverPadding(
                padding: EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 20),
                    scheduleCard(snapshot.data),
                  ]),
                ),
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
  final int plantId;

  final _plantController = BehaviorSubject<Plant>();

  PlantInfoBloc({this.plantRepository, this.plantId});

  Stream<Plant> get plantStream => _plantController.stream;

  Plant get plant => _plantController.value;

  Future<void> getPlantById() {
    return plantRepository
        .getById(plantId)
        .then(_plantController.add)
        .catchError((error) => _plantController.addError(
              "Failed to fetch plant. Please try again later",
            ));
  }

  void dispose() {
    _plantController.close();
  }
}
