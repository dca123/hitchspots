import 'package:flutter/material.dart';

Future<void> showAlertDialog(
    {required BuildContext context,
    required String title,
    required String body,
    String? ActionOneTitle,
    Function? ActionOne,
    String? ActionTwoTitle,
    Function? ActionTwo}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Container(
        child: AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            if (ActionTwoTitle != null)
              TextButton(
                child: Text(ActionTwoTitle),
                onPressed: () {
                  if (ActionTwo != null) {
                    ActionTwo();
                  }
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: Text(ActionOneTitle ?? "OK"),
              onPressed: () {
                if (ActionOne != null) {
                  ActionOne();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
