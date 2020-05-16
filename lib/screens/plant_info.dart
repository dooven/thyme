import 'dart:io';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/screens/home.dart';
import 'package:boopplant/screens/plant_add.dart';
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
  PlantListBloc _plantListBloc;
  PlantInfoScreenArguments _screenArguments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenArguments = ModalRoute.of(context).settings.arguments;

    _plantListBloc = Provider.of<PlantListBloc>(context);
    _plantInfoBloc = PlantInfoBloc(
      plantId: _screenArguments.id,
      repository: PlantRepository(
        database: Provider.of<Database>(context),
      ),
    );
    _plantInfoBloc.getPlantById();
  }

  Widget plantName(Plant plant) {
    return Text(
      plant.name,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  void addPlant(Plant plant) {
    Navigator.of(context)
        .pushNamed(
      TabNavigatorRoutes.plantModify,
      arguments: PlantModifyScreenArgument(plantId: plant.id),
    )
        .then((value) {
      if (value) {
        _plantListBloc.plantListFetchSink(true);
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
              onPressed: () => addPlant(snapshot.data),
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
