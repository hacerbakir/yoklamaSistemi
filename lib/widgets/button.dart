import 'package:flutter/material.dart';

Widget customButton(void Function() doThis, String text, Widget icon) {
  return MaterialButton(
    elevation: 0,
    padding: EdgeInsets.symmetric(horizontal: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    onPressed: doThis,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
    color: Colors.lightBlue,
  );
}
