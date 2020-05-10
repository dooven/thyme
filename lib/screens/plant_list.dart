import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/plant.dart';
import 'package:boopplant/screens/plant_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class PlantList extends StatelessWidget {
  buildListItem(Plant plant) {
    return Builder(
      builder: (context) {
        return ListTile(
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
    final plantRepository =
        PlantRepository(database: Provider.of<Database>(context));

    return Scaffold(
      body: Column(
        children: [
          RaisedButton(
            child: Text("Add plant"),
            onPressed: () async {
              final res = await Navigator.of(context).pushNamed('/plant/add');
              if(res == null) {

              }
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
