import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class PlantAdd extends StatefulWidget {
  @override
  _PlantAddState createState() => _PlantAddState();
}

class _PlantAddState extends State<PlantAdd> {
  PlantAddBloc _plantAddBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _plantAddBloc = PlantAddBloc(
      plantRepository:
          PlantRepository(database: Provider.of<Database>(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("SUP"),
      ),
    );
  }
}

class PlantAddBloc {
  final PlantRepository plantRepository;

  PlantAddBloc({this.plantRepository});

  Future<void> insert({@required String name}) {
    return this.plantRepository.insert(Plant(
          name: name,
          createdAt: DateTime.now(),
        ));
  }
}
