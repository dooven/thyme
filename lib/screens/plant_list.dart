import 'dart:async';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/screens/plant_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class PlantList extends StatefulWidget {
  @override
  _PlantListState createState() => _PlantListState();
}

class _PlantListState extends State<PlantList> {
  PlantListBloc _plantListBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _plantListBloc = PlantListBloc(
        PlantRepository(database: Provider.of<Database>(context)));
    _plantListBloc.plantListFetchSink(true);
  }

  buildListItem(Plant plant) {
    final hasImageURL = plant.imageUrl != null;
    return Builder(
      builder: (context) {
        return ListTile(
          leading: CircleAvatar(
            child: !hasImageURL
                ? Text(
                    plant.name.substring(0, 1),
                    style: TextStyle(color: Colors.white),
                  )
                : null,
            backgroundColor: Theme.of(context).backgroundColor,
            backgroundImage: hasImageURL ? AssetImage(plant.imageUrl) : null,
          ),
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
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Plant>>(
              stream: _plantListBloc.plantList,
              builder: (context, snapshot) {
                print(snapshot.data);
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return buildListItem(snapshot.data[index]);
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.of(context).pushNamed('/plant/add');
          if (res == null) {
            _plantListBloc.plantListFetchSink(true);
          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Container(height: 50)]),
        shape: CircularNotchedRectangle(),
        color: Theme.of(context).backgroundColor,
      ),
    );
  }
}

class PlantListBloc {
  final _plantListFetchController = BehaviorSubject<bool>();
  final PlantRepository _plantRepository;

  Stream<bool> get plantListFetchStream => _plantListFetchController.stream;

  Function(bool) get plantListFetchSink => _plantListFetchController.sink.add;

  Stream<List<Plant>> get plantList => plantListFetchStream.transform(
        StreamTransformer<bool, List<Plant>>.fromHandlers(
          handleData: (data, sink) async {
            sink.add(null);
            try {
              final result = await this._plantRepository.list();
              sink.add(result);
            } catch (e) {
              sink.addError(e);
            }
          },
        ),
      );

  PlantListBloc(this._plantRepository);

  void dispose() {
    _plantListFetchController.close();
  }
}
