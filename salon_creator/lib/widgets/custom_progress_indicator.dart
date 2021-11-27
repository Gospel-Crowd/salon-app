import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.headline3),
          SizedBox(
            height: 16,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 8,
            ),
          ),
        ],
      ),
    );
  }
}
