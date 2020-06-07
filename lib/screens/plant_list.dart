import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/screens/plant_info.dart';
import 'package:boopplant/widgets/plant_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class PlantList extends StatefulWidget {
  @override
  _PlantListState createState() => _PlantListState();
}

class _PlantListState extends State<PlantList> {
  PlantListBloc _plantListBloc;
  Stream fetcher;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _plantListBloc = Provider.of<PlantListBloc>(context);
    fetcher = _plantListBloc.plantListFetcher;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Plant>>(
      stream: _plantListBloc.plantListFetcher,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: _plantListBloc.plantList.length,
          itemBuilder: (context, index) {
            return buildListItem(_plantListBloc.plantList[index]);
          },
        );
      },
    );
  }
}

class PlantListBloc {
  final _allPlantsFetchController = BehaviorSubject<bool>.seeded(true);
  final _plantListController = BehaviorSubject<List<Plant>>();

  Stream<bool> globalRefreshStream;
  final PlantRepository _plantRepository;

  Stream<void> get plantListFetcher => globalRefreshStream
      .startWith(true)
      .asyncMap((event) => this._plantRepository.list())
      .doOnData(_plantListController.add);

  List<Plant> get plantList => _plantListController.value;

  PlantListBloc(this._plantRepository);

  void dispose() {
    _allPlantsFetchController.close();
    _plantListController.close();
  }
}
