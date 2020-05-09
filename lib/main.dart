import 'package:boopplant/database.dart';
import 'package:boopplant/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(
          create: (_) => LocalDatabase().setupDb(),
          lazy: false,
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (_) => Schedule(),
        },
      ),
    );
  }
}
