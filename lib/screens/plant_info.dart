import 'dart:io';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final PlantInfoScreenArguments args =
        ModalRoute.of(context).settings.arguments;
    _plantInfoBloc = PlantInfoBloc(
      PlantRepository(
        database: Provider.of<Database>(context),
      ),
    );
    _plantInfoBloc.getPlantById(args.id);
  }

  Widget plantName(Plant plant) {
    return Text(
      plant.name,
      style: Theme.of(context).textTheme.headline5,
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

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                expandedHeight: 300.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (snapshot.data.imageUrl != null)
                        Image.file(
                          File(snapshot.data.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.0, 0.5),
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
                    snapshot.data.name,
                    style: TextStyle(color: Colors.white),
                  ),
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

  final _plantController = BehaviorSubject<Plant>();

  PlantInfoBloc(this.repository);

  Stream<Plant> get plantStream => _plantController.stream;

  Plant get plant => _plantController.value;

  Future<void> getPlantById(int id) {
    return repository
        .getById(id)
        .then(_plantController.add)
        .catchError((error) => _plantController.addError(
              "Failed to fetch plant. Please try again later",
            ));
  }

  void dispose() {
    _plantController.close();
  }
}
