import 'package:Face_recognition/pages/lecturerops/addface.dart';
import 'package:Face_recognition/pages/auth/register.dart';
import 'package:Face_recognition/utils/consts.dart';
import 'package:Face_recognition/utils/textfdecoration.dart';
import 'package:Face_recognition/widgets/button.dart';
import 'package:Face_recognition/widgets/title.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddStudent extends StatefulWidget {
  AddStudent();
  @override
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  void initState() {
    Firebase.initializeApp();
    super.initState();
    //getCurrentUser();
  }

  String? nameSurname;
  String? no;
  String? mail;

  final _auth = FirebaseAuth.instance;

  User? loggedInUser;

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
                "Öğrenci Ekle\n",
                style: TextStyle(
                    color: Colors.black87.withOpacity(0.8),
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
              ),
              TextField(
                  onChanged: (value) {
                    nameSurname = value;
                  },
                  cursorColor: Colors.grey,
                  decoration: textfieldDec("Ad Soyad")),
              SizedBox(
                height: 10,
              ),
              TextField(
                  onChanged: (value) {
                    no = value;
                  },
                  cursorColor: Colors.grey,
                  decoration: textfieldDec("Öğrenci No")),
              SizedBox(
                height: 10,
              ),
              TextField(
                  onChanged: (value) {
                    mail = value;
                  },
                  cursorColor: Colors.grey,
                  decoration: textfieldDec("Öğrenci E-Posta")),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Bir sonraki sayfada öğrenci fotoğrafı \nçekmeniz istenecektir.',
                    style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  customButton(() async {
                    Route route = MaterialPageRoute(
                        builder: (context) => AddFace(
                            nameSurname: nameSurname!, no: no!, email: mail!));
                    Navigator.push(context, route);
                  },
                      'Öğrenci Ekle',
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
