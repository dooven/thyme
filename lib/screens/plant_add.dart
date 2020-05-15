import 'dart:async';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/screens/screens.dart';
import 'package:boopplant/widgets/plant_image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class PlantAddScreenArgument {
  final int plantId;

  PlantAddScreenArgument({this.plantId});
}

class PlantAdd extends StatefulWidget {
  @override
  _PlantAddState createState() => _PlantAddState();
}

class _PlantAddState extends State<PlantAdd> {
  PlantAddBloc _plantAddBloc;
  final _plantNameController = new TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PlantAddScreenArgument screenArgument =
        ModalRoute.of(context).settings.arguments;
    _plantAddBloc = PlantAddBloc(
      plantId: screenArgument?.plantId,
      plantRepository: PlantRepository(
        database: Provider.of<Database>(context),
      ),
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
        appBar: AppBar(
          title: Text('Add a plant'),
        ),
        body: Container(
          margin: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SizedBox(height: 8),
              nameField(),
              SizedBox(height: 16),
              imagePreview(),
              SizedBox(height: 16),
              submitButton(),
            ],
          ),
        ),
      ),
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
        _plantNameController.value =
            _plantNameController.value.copyWith(text: snapshot.data);
        return TextFormField(
          controller: _plantNameController,
          onChanged: _plantAddBloc.changePlantName,
          decoration: InputDecoration(
            errorText: snapshot.error,
            labelText: "Plant Name",
          ),
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
                    _plantAddBloc.save().then((id) {
                      if (_plantAddBloc.isEditing) {
                        Navigator.pop(context);
                      } else {
                        Navigator.of(context).pushReplacementNamed(
                            '/plant/info',
                            arguments: PlantInfoScreenArguments(id: id));
                      }
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
    _plantNameController.dispose();
    _plantAddBloc.dispose();
    super.dispose();
  }
}

class PlantAddBloc {
  final PlantRepository plantRepository;
  final int plantId;
  final _plantNameController = BehaviorSubject<String>();
  final _imageURLController = BehaviorSubject<String>();
  final _submitLoadingController = BehaviorSubject<bool>();

  Stream<String> get plantName =>
      _plantNameController.stream.transform(validateName);

  bool get isEditing => plantId != null;

  Stream<String> get imageUrl => _imageURLController.stream;

  Stream<bool> get canSubmit => plantName.mapTo(true);

  Stream<bool> get submitLoading =>
      _submitLoadingController.stream.startWith(false);

  Function(String) get changePlantName => _plantNameController.sink.add;

  Function(String) get changeImageURl => _imageURLController.sink.add;

  PlantAddBloc({this.plantRepository, this.plantId}) {
    if (plantId != null) {
      this.plantRepository.getById(plantId).then(
        (value) {
          _plantNameController.add(value.name);
          _imageURLController.add(value.imageUrl);
        },
      );
    }
  }

  Future<Plant> insert() {
    return this.plantRepository.insert(Plant(
          name: _plantNameController.value,
          imageUrl: _imageURLController.value,
          createdAt: DateTime.now(),
        ));
  }

  Future<int> update() {
    return this.plantRepository.update(
          this.plantId,
          name: _plantNameController.value,
          imageUrl: _imageURLController.value,
        );
  }

  Future<int> save() async {
    int id = plantId;
    _submitLoadingController.add(true);
    try {
      if (plantId == null) {
        final res = await insert();
        id = res.id;
      } else {
        await update();
      }
    } finally {
      _submitLoadingController.add(false);
    }

    return id;
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
