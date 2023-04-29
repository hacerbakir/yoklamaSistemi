import 'package:flutter/material.dart';

InputDecoration textfieldDec(String hinttext) {
  return InputDecoration(
      contentPadding: EdgeInsets.all(15),
      filled: true,
      fillColor: Color(0xFFF1F1F1),
      hintText: hinttext,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 19),
      border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(15.0))));
}
