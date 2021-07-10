import 'package:flutter/material.dart';
import 'package:salon_creator/widgets/custom_label.dart';

Widget customTextFieldWithLabel({
  TextEditingController controller,
  double height,
  double width,
  TextInputType keyboardType,
  String title,
  double labelWidth,
  double labelHeight,
  String hintText,
}) {
  return Container(
    height: height,
    width: width,
    child: Column(
      children: [
        CustomLabel(
          title: title,
          width: labelWidth,
          height: labelHeight,
        ),
        SizedBox(
          height: 12,
        ),
        Container(
          height: 32,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              height: 1,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 0.5,
                ),
              ),
              hintText: hintText,
            ),
          ),
        ),
      ],
    ),
  );
}
