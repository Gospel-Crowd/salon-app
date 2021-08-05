import 'package:flutter/material.dart';
import 'package:salon_creator/widgets/custom_label.dart';

class TextFieldWithLabel extends StatefulWidget {
  const TextFieldWithLabel(
      {Key key,
      this.controller,
      this.height,
      this.width,
      this.keyboardType,
      this.title,
      this.labelWidth,
      this.labelHeight,
      this.hintText,
      this.maxLength,
      this.onChanged,
      this.maxLines})
      : super(key: key);

  final int maxLength;
  final int maxLines;
  final TextEditingController controller;
  final double height;
  final double width;
  final TextInputType keyboardType;
  final String title;
  final double labelWidth;
  final double labelHeight;
  final String hintText;
  final Function onChanged;

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
          _buildCustomTextField(),
        ],
      ),
    );
  }

  Widget _buildCustomTextField() {
    return Container(
      height: 32,
      child: TextField(
        onChanged: widget.onChanged,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        style: TextStyle(
          fontSize: 16,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
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
          hintText: widget.hintText,
        ),
      ),
    );
  }
}
