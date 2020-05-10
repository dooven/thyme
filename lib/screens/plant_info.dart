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

          return Center(
            child: Text(snapshot.data.name),
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
