import 'dart:io';

import 'package:boopplant/models/models.dart';
import 'package:boopplant/screens/plant_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
        heroTag: "add-fab",
        onPressed: () async {
          final nav = context.read<FlutterLocalNotificationsPlugin>();
          // await nav.cancelAll();

          var androidPlatformChannelSpecifics = AndroidNotificationDetails(
              'your channel id',
              'your channel name',
              'your channel description',
              importance: Importance.Max,
              priority: Priority.High,
              ticker: 'ticker');
          var iOSPlatformChannelSpecifics = IOSNotificationDetails();
          var platformChannelSpecifics = NotificationDetails(
              androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

          await nav
              .periodicallyShow(0, 'repeating title', 'repeating body',
                  RepeatInterval.EveryMinute, platformChannelSpecifics)
              .catchError((error) {
            print(error);
          });
          Navigator.of(context).pushNamed(TabNavigatorRoutes.plantModify);
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
