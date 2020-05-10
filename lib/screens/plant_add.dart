import 'dart:async';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/screens/screens.dart';
import 'package:boopplant/widgets/plant_image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return true;
      },
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.all(20.0),
          child: ListView(
            children: [
              SizedBox(height: 24),
              nameField(),
              SizedBox(height: 24),
              imagePreview(),
              SizedBox(height: 24),
              submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget takePicture() {
    return RaisedButton(
      child: Text("Take picture"),
      onPressed: () async {
        final imageUrl =
            await ImagePicker.pickImage(source: ImageSource.camera);
        _plantAddBloc.changeImageURl(imageUrl.path);
      },
    );
  }

  Widget imagePreview() {
    return StreamBuilder<String>(
      stream: _plantAddBloc.imageUrl,
      builder: (context, snapshot) {
        return PlantImagePicker(
          imageUrl: snapshot.data,
          onImageChangeCallback: _plantAddBloc.changeImageURl,
        );
      },
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
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: RaisedButton(
            child: StreamBuilder(
              stream: _plantAddBloc.submitLoading,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data) {
                  return CircularProgressIndicator();
                }

                return Text("Submit");
              },
            ),
            onPressed: snapshot.hasData
                ? () {
                    _plantAddBloc.insert().then((plant) {
                      Navigator.of(context).pushReplacementNamed('/plant/info',
                          arguments: PlantInfoScreenArguments(id: plant.id));
                    });
                  }
                : null,
          ),
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
  final _imageURLController = BehaviorSubject<String>();
  final _submitLoadingController = BehaviorSubject<bool>();

  Stream<String> get plantName =>
      _plantNameController.stream.transform(validateName);

  Stream<String> get imageUrl => _imageURLController.stream;

  Stream<bool> get canSubmit => plantName.mapTo(true);

  Stream<bool> get submitLoading =>
      _submitLoadingController.stream.startWith(false);

  Function(String) get changePlantName => _plantNameController.sink.add;

  Function(String) get changeImageURl => _imageURLController.sink.add;

  PlantAddBloc({this.plantRepository});

  Future<Plant> insert() {
    _submitLoadingController.add(true);
    return this
        .plantRepository
        .insert(Plant(
          name: _plantNameController.value,
          imageUrl: _imageURLController.value,
          createdAt: DateTime.now(),
        ))
        .whenComplete(() => _submitLoadingController.add(false));
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
    _imageURLController.close();
  }
}
