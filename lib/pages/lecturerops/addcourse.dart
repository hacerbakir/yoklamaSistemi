import 'package:Face_recognition/pages/lecturerops/addface.dart';
import 'package:Face_recognition/pages/auth/register.dart';
import 'package:Face_recognition/utils/textfdecoration.dart';
import 'package:Face_recognition/widgets/button.dart';
import 'package:Face_recognition/widgets/dialog.dart';
import 'package:Face_recognition/widgets/title.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCourse extends StatefulWidget {
  AddCourse();
  @override
  _AddCourseState createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  void initState() {
    Firebase.initializeApp();
    super.initState();
    //getCurrentUser();
  }

  String? code;

  String? name;
  String? desc;

  String? days;

  String? semester;
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
                "Dersler\n",
                style: TextStyle(
                    color: Colors.black87.withOpacity(0.8),
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
              ),
              TextField(
                onChanged: (value) {
                  code = value;
                },
                cursorColor: Colors.grey,
                decoration: textfieldDec('Kodu'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (value) {
                  name = value;
                },
                cursorColor: Colors.grey,
                decoration: textfieldDec('Ders Adı'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (value) {
                  desc = value;
                },
                cursorColor: Colors.grey,
                decoration: textfieldDec('Ders Açıklaması'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (value) {
                  semester = value;
                },
                cursorColor: Colors.grey,
                decoration: textfieldDec('Dönem'),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  customButton(() async {
                    
                    createData(String userid) {
                      DocumentReference documentReference = FirebaseFirestore
                          .instance
                          .collection('teachers')
                          .doc(userid)
                          .collection('courses')
                          .doc(code);
                      Map<String, dynamic> dish = {
                        "code": code,
                        "name": name,
                        "desc": desc,
                        "semester": semester,
                      };
                      documentReference.set(dish).whenComplete(() {
                        print(' created');
                      });
                      Navigator.pop(context);
                      openAlertBox(context, "Başarılı", "Ders Eklendi");
                    }


                    createData(_auth.currentUser!.email!);
                  }, 'Ders Ekle', Icon(Icons.add, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
