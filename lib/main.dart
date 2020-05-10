import 'package:boopplant/database.dart';
import 'package:boopplant/screens/screens.dart';
import 'package:boopplant/screens/startupcontroller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider<Database>(
          create: (_) => LocalDatabase().setupDb(),
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        builder: (context, child) {
          return SafeArea(
            child: child,
          );
        },
        routes: {
          '/': (_) => StartupController(),
          '/plant/add': (_) => PlantAdd(),
          '/plant/info': (_) => PlantInfo(),
        },
      ),
    );
  }
}
