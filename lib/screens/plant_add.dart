import 'dart:async';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
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
      body: Container(
        margin: EdgeInsets.all(20.0),
        child: Column(
          children: [
            nameField(),
            submitButton(),
          ],
        ),
      ),
    );
  }

  Widget nameField() {
    return StreamBuilder(
      stream: _plantAddBloc.plantName,
      builder: (context, snapshot) {
        return TextField(
          onChanged: _plantAddBloc.changePlantName,
          decoration: InputDecoration(
              errorText: snapshot.error, labelText: "Plant Name"),
        );
      },
    );
  }

  Widget submitButton() {
    return StreamBuilder(
      stream: _plantAddBloc.canSubmit,
      builder: (context, snapshot) {
        return RaisedButton(
          child: StreamBuilder(
            stream: _plantAddBloc.submitLoading,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data) {
                return CircularProgressIndicator();
              }

              return Text("Submit");
            },
          ),
          color: Theme.of(context).primaryColor,
          onPressed: snapshot.hasData
              ? () async {
                  await _plantAddBloc.insert();
                }
              : null,
        );
      },
    );
  }

  @override
  void dispose() {
    _plantAddBloc.dispose();
    super.dispose();
  }
}

class PlantAddBloc {
  final PlantRepository plantRepository;
  final _plantNameController = BehaviorSubject<String>();
  final _submitLoadingController = BehaviorSubject<bool>();

  Stream<String> get plantName =>
      _plantNameController.stream.transform(validateName);

  Stream<bool> get canSubmit => plantName.mapTo(true);

  Stream<bool> get submitLoading =>
      _submitLoadingController.stream.startWith(false);

  Function(String) get changePlantName => _plantNameController.sink.add;

  PlantAddBloc({this.plantRepository});

  Future<void> insert() {
    _submitLoadingController.add(true);
    return this
        .plantRepository
        .insert(Plant(
          name: _plantNameController.value,
          createdAt: DateTime.now(),
        ))
        .then((value) => _submitLoadingController.add(false));
  }

  final validateName = StreamTransformer<String, String>.fromHandlers(
      handleData: (plantName, sink) {
    if (plantName.trim().length > 0) {
      sink.add(plantName);
    } else {
      sink.addError('Name is required');
    }
  });

  void dispose() {
    _plantNameController.close();
    _submitLoadingController.close();
  }
}
