import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class PlantList extends StatelessWidget {
  buildListItem(Plant plant) {
    return ListTile(
      title: Text(plant.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantRepository =
        PlantRepository(database: Provider.of<Database>(context));

    return Scaffold(
      body: Column(
        children: [
          RaisedButton(
            child: Text("Add plant"),
            onPressed: () {
              Navigator.of(context).pushNamed('/plant/add');
            },
          ),
          Expanded(
            child: FutureBuilder<List<Plant>>(
              future: plantRepository.list(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return CircularProgressIndicator();
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
    );
  }
}
