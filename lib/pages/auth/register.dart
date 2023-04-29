import 'package:Face_recognition/pages/lecturerops/addface.dart';
import 'package:Face_recognition/pages/lecturerhome.dart';
import 'package:Face_recognition/utils/textfdecoration.dart';
import 'package:Face_recognition/widgets/button.dart';
import 'package:Face_recognition/widgets/dialog.dart';
import 'package:Face_recognition/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  Register({required this.type});
  String type;
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  void initState() {
    super.initState();
    // getCurrentUser();
  }

  String? email;
  String? password;
  String? namesurname;

  final _auth = FirebaseAuth.instance;

  User? loggedInUser;

  createData(String userid) {
    if (widget.type == 'Teacher') {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('teachers').doc(userid);
      Map<String, dynamic> dish = {
        "title": "title",
        "content": "content",
        "color": "pageColor",
        "date": "sdf",
      };
      documentReference.set(dish).whenComplete(() {
        print(' created');
      });
    } else {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('students').doc(userid);
      Map<String, dynamic> dish = {
        "title": "title",
        "content": "content",
        "color": "pageColor",
        "date": "sdf",
      };
      documentReference.set(dish).whenComplete(() {
        print(' created');
      });
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
                "Kayıt Ol\n",
                style: TextStyle(
                    color: Colors.black87.withOpacity(0.8),
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
              ),
              TextField(
                onChanged: (value) {
                  namesurname = value;
                },
                cursorColor: Colors.grey,
                decoration: textfieldDec("Ad Soyad"),
              ),
              SizedBox(
                height: 10,
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
                decoration: textfieldDec("Şifre"),
              ),
              SizedBox(
                height: 10,
              ),
              customButton(
                () async {
                  try {
                    final newUser = await _auth
                        .createUserWithEmailAndPassword(
                            email: email!, password: password!)
                        .then((value) {
                      value.user!.updateDisplayName(namesurname);
                    });
                     openAlertBox(context, "asds", "Kayıt başarılı.");
                  } catch (e) {
                    print(e);
                  }
                },
                'Kayıt Ol',
                Icon(Icons.app_registration_rounded, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
