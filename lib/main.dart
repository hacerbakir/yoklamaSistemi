import 'package:Face_recognition/pages/auth/login.dart';
import 'package:Face_recognition/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this

  await Firebase.initializeApp();
  runApp(MaterialApp(
    themeMode: ThemeMode.light,
    theme:
        ThemeData(brightness: Brightness.light, primaryColor: Colors.lightBlue),
    home: Login(
      type: 'Lecturer',
    ),
    title: "Yoklama Sistemi",
    debugShowCheckedModeBanner: false,
  ));
}
