import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PlantImagePicker extends StatelessWidget {
  final Function(String) onImageChangeCallback;
  final String imageUrl;

  const PlantImagePicker({
    Key key,
    @required this.onImageChangeCallback,
    @required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null;

    return Container(
      constraints: new BoxConstraints.expand(
        height: 200.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: hasImage ? null : Colors.grey,
        image: hasImage
            ? DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      height: 50,
      child: Stack(
        children: [
          if (!hasImage) Center(child: Text("No Image")),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
              onPressed: () async {
                final imageUrl = await ImagePicker.pickImage(
                  source: ImageSource.camera,
                );

                this.onImageChangeCallback(imageUrl.path);
              },
            ),
          ),
        ],
      ),
    );
  }
}
