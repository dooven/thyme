import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonRow extends StatelessWidget {
  final Function onTap;
  final EdgeInsets padding;
  final Text text;
  final Icon icon;

  ButtonRow({
    this.onTap,
    this.padding,
    this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            icon,
            SizedBox(
              width: 8,
            ),
            text
          ],
        ),
      ),
    );
  }
}
