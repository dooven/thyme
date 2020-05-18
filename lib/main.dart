import 'package:boopplant/blocs/bloc.dart';
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
        Provider<DatabaseBloc>(
          create: (_) => DatabaseBloc()..bootStrapDatabase(),
        ),
        ProxyProvider<DatabaseBloc, Database>(
          update: (context, bloc, _) => bloc.database,
        ),
        FutureProvider<CameraDescription>(
          create: (_) => availableCameras()
              .then((value) => value.isEmpty ? null : value.first),
          lazy: false,
        ),
        Provider<NotificationBloc>(
          create: (_) => NotificationBloc()..initializePlugin(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.lightGreen[300],
            primarySwatch: Colors.lightGreen,
            accentColor: Colors.orangeAccent[200],
            visualDensity: VisualDensity.adaptivePlatformDensity,
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.orangeAccent[200],
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
        initialRoute: '/',
        routes: {
          '/': (_) => StartupController(),
        },
      ),
    );
  }
}
