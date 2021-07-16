import 'package:flutter/material.dart';

void showCustomDialog({
  title,
  content,
  leftFunction,
  leftButtonText,
  rightFunction,
  rightButtonText,
  context,
}) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        title: title,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogText(content),
            Container(
              color: Theme.of(context).primaryColor,
              child: _buildDialogButtons(
                leftFunction,
                leftButtonText,
                rightFunction,
                rightButtonText,
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDialogText(content) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    child: Text(
      content,
      textAlign: TextAlign.center,
    ),
  );
}

Widget _buildDialogButtons(
  leftFunction,
  leftButtonText,
  rightFunction,
  rightButtonText,
) {
  return Row(
    children: [
      Expanded(
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
          onPressed: leftFunction,
          child: Text(
            leftButtonText,
          ),
        ),
      ),
      VerticalDivider(
        width: 1,
        thickness: 1,
      ),
      Expanded(
        child: TextButton(
          onPressed: rightFunction,
          child: Text(
            rightButtonText,
          ),
        ),
      ),
    ],
  );
}
