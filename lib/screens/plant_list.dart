import 'dart:io';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/screens/plant_info.dart';
import 'package:boopplant/widgets/plant_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class PlantList extends StatelessWidget {
  buildListItem(Plant plant) {
    return Builder(
      builder: (context) {
        return ListTile(
          leading: PlantCircleAvatar(imageUrl: plant.imageUrl),
          title: Text(plant.name),
          onTap: () {
            Navigator.of(context).pushNamed('/plant/info',
                arguments: PlantInfoScreenArguments(id: plant.id));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantListBloc = Provider.of<PlantListBloc>(context);

    return StreamBuilder<List<Plant>>(
      stream: plantListBloc.plantListFetcher,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: plantListBloc.plantList.length,
          itemBuilder: (context, index) {
            return buildListItem(plantListBloc.plantList[index]);
          },
        );
      },
    );
  }
}

class PlantListBloc {
  final _allPlantsFetchController = BehaviorSubject<bool>.seeded(true);
  final _singlePlantFetchController = BehaviorSubject<int>();
  final _plantListController = BehaviorSubject<List<Plant>>();

  final PlantRepository _plantRepository;

  Stream<bool> get plantListFetchStream => _allPlantsFetchController.stream;

  Function(bool) get plantListFetchSink => _allPlantsFetchController.sink.add;

  Stream<void> get plantListFetcher => plantListFetchStream
      .asyncMap((event) => this._plantRepository.list())
      .doOnData(_plantListController.add);

  List<Plant> get plantList => _plantListController.value;

  PlantListBloc(this._plantRepository);

  void dispose() {
    _allPlantsFetchController.close();
    _plantListController.close();
    _singlePlantFetchController.close();
  }
}
