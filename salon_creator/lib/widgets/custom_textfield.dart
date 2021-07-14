import 'package:flutter/material.dart';
import 'package:salon_creator/widgets/custom_label.dart';

class TextFieldWithLabel extends StatefulWidget {
  const TextFieldWithLabel({
    Key key,
    this.controller,
    this.height,
    this.width,
    this.keyboardType,
    this.title,
    this.labelWidth,
    this.labelHeight,
    this.hintText,
  }) : super(key: key);
  final TextEditingController controller;
  final double height;
  final double width;
  final TextInputType keyboardType;
  final String title;
  final double labelWidth;
  final double labelHeight;
  final String hintText;

  @override
  _TextFieldWithLabelState createState() => _TextFieldWithLabelState();
}

class _TextFieldWithLabelState extends State<TextFieldWithLabel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: Column(
        children: [
          CustomLabel(
            title: widget.title,
            width: widget.labelWidth,
            height: widget.labelHeight,
          ),
          SizedBox(
            height: 12,
          ),
          _buildCustoTextField(
              widget.controller, widget.keyboardType, widget.hintText),
        ],
      ),
    );
  }
}

Widget _buildCustoTextField(TextEditingController controller,
    TextInputType keyboardType, String hintText) {
  return Container(
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
  );
}
