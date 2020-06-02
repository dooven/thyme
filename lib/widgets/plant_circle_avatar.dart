import 'dart:io';

import 'package:flutter/material.dart';

class PlantCircleAvatar extends StatelessWidget {
  final String imageUrl;

  const PlantCircleAvatar({Key key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImageURL = imageUrl != null;

    return CircleAvatar(
      child: hasImageURL
          ? Text(
              imageUrl.substring(0, 1),
              style: TextStyle(color: Colors.white),
            )
          : null,
      backgroundColor: Theme.of(context).backgroundColor,
      backgroundImage: hasImageURL ? FileImage(File(imageUrl)) : null,
    );
  }
}
