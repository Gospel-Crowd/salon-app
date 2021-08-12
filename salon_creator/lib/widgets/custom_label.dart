import 'package:flutter/material.dart';

class CustomLabel extends StatelessWidget {
  const CustomLabel({Key key, this.title, this.color, this.width, this.height})
      : super(key: key);
  final title;
  final color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 4),
        Text(title, style: Theme.of(context).textTheme.headline3),
      ],
    );
  }
}
