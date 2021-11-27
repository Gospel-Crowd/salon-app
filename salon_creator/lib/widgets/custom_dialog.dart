import 'package:flutter/material.dart';

void showCustomDialog({
  Text title,
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
        title: Align(child: title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogText(content),
            Container(
              color: Theme.of(context).primaryColor,
              child: _buildDialogButtons(
                context,
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
  context,
  leftFunction,
  leftButtonText,
  rightFunction,
  rightButtonText,
) {
  return Row(
    children: [
      Expanded(
        child: TextButton(
          style: Theme.of(context).textButtonTheme.style.copyWith(
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
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.white),
          ),
        ),
      ),
    ],
  );
}
