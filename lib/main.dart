import 'package:boopplant/database.dart';
import 'package:boopplant/screens/screens.dart';
import 'package:boopplant/screens/startupcontroller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider<Database>(
          create: (_) => LocalDatabase().setupDb(),
        ),
        FutureProvider<CameraDescription>(
          create: (_) => availableCameras()
              .then((value) => value.isEmpty ? null : value.first),
          lazy: false,
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
            appBarTheme: AppBarTheme(
              color: Colors.lightGreen[200],
            ),
            primarySwatch: Colors.lightGreen,
            accentColor: Colors.blueGrey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.blueGrey[500],
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)))),
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
