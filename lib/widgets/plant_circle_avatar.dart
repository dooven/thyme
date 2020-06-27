import 'dart:io';

import 'package:flutter/material.dart';

class PlantCircleAvatar extends StatelessWidget {
  final String imageUrl;

  const PlantCircleAvatar({Key key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImageURL = imageUrl != null;

    return CircleAvatar(
      backgroundColor: Theme.of(context).backgroundColor,
      backgroundImage: hasImageURL ? FileImage(File(imageUrl)) : null,
    );
  }
}
