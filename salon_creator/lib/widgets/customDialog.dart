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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                content,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                      ),
                      onPressed: leftFunction,
                      child: Text(leftButtonText),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: rightFunction,
                      child: Text(rightButtonText),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
