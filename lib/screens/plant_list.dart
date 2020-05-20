import 'dart:io';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/screens/plant_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class PlantList extends StatelessWidget {
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
            backgroundImage:
                hasImageURL ? FileImage(File(plant.imageUrl)) : null,
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
    final plantListBloc = Provider.of<PlantListBloc>(context);

    plantListBloc.plantListFetchSink(true);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Plant>>(
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
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(TabNavigatorRoutes.plantModify),
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
