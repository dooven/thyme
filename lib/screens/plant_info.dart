import 'dart:io';

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

class PlantInfo extends StatefulWidget {
  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo> {
  PlantInfoBloc _plantInfoBloc;
  PlantInfoScreenArguments _screenArguments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenArguments = ModalRoute.of(context).settings.arguments;

    _plantInfoBloc = PlantInfoBloc(
      plantId: _screenArguments.id,
      repository: PlantRepository(database: context.read<Database>()),
    );
    _plantInfoBloc.getPlantById();
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
      children: ['S', 'M', 'T', 'W', 'T', 'F']
          .map((day) => Container(
                width: 30,
                height: 30,
                margin: EdgeInsets.only(right: 16.0, top: 8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: Center(child: Text(day)),
              ))
          .toList(),
    );
  }

  Widget scheduleCard() {
    return Card(
      child: Container(
        margin: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "8:00 am",
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.black),
            ),
            dayList(),
            RaisedButton(
              child: Text("hi"),
              onPressed: () async {
                final selectedTime = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());

                final dateTime = DateTime.fromMillisecondsSinceEpoch(0).add(Duration(
                    hours: selectedTime.hour, minutes: selectedTime.minute));

                print(dateTime);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Plant>(
        stream: _plantInfoBloc.plantStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
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
                  delegate: SliverChildListDelegate(
                      [SizedBox(height: 20), scheduleCard()]),
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
  final PlantRepository repository;
  final int plantId;

  final _plantController = BehaviorSubject<Plant>();

  PlantInfoBloc({this.repository, this.plantId});

  Stream<Plant> get plantStream => _plantController.stream;

  Plant get plant => _plantController.value;

  Future<void> getPlantById() {
    return repository
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
