import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Schedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("$index"),
          );
        },
      ),
    );
  }
}
