import 'package:Face_recognition/pages/lecturerops/addface.dart';
import 'package:Face_recognition/pages/auth/register.dart';
import 'package:Face_recognition/pages/lecturerhome.dart';
import 'package:Face_recognition/utils/textfdecoration.dart';
import 'package:Face_recognition/widgets/button.dart';
import 'package:Face_recognition/widgets/title.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  Login({required this.type});
  String type;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void initState() {
    Firebase.initializeApp();
    super.initState();
    getCurrentUser();
  }

  String? email;
  String? password;
  final _auth = FirebaseAuth.instance;

  User? loggedInUser;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        Route route = MaterialPageRoute(builder: (context) => TeacherHome());
        Navigator.push(context, route);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              title(),
              Text(
                "Giriş Yap\n",
                style: TextStyle(
                    color: Colors.black87.withOpacity(0.8),
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 30,
              ),
              TextField(
                  onChanged: (value) {
                    email = value;
                  },
                  cursorColor: Colors.grey,
                  decoration: textfieldDec("E-Posta")),
              SizedBox(
                height: 10,
              ),
              TextField(
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  cursorColor: Colors.grey,
                  decoration: textfieldDec("Şifre")),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  
                  customButton(() async {
                    try {
                      await _auth
                          .signInWithEmailAndPassword(
                              email: email!, password: password!)
                          .then((value) {
                        Route route = MaterialPageRoute(
                            builder: (context) => TeacherHome());
                        Navigator.push(context, route);
                      });
                    } catch (e) {
                      print(e);
                    }
                  },

                      'Giriş Yap',
                      Icon(
                        Icons.login,
                        color: Colors.white,
                      )),
                  SizedBox(
                    width: 8,
                  ),
                  MaterialButton(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.lightBlueAccent,
                    onPressed: () async {
                      Route route = MaterialPageRoute(
                          builder: (context) => Register(type: widget.type));
                      Navigator.push(context, route);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.app_registration, color: Colors.white),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Kayıt Ol',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
