import 'package:Face_recognition/pages/lecturerops/addface.dart';
import 'package:Face_recognition/pages/auth/register.dart';
import 'package:Face_recognition/pages/lecturerops/addcourse.dart';
import 'package:Face_recognition/pages/lecturerops/courses.dart';
import 'package:Face_recognition/pages/lecturerops/students.dart';
import 'package:Face_recognition/utils/consts.dart';
import 'package:Face_recognition/widgets/title.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'lecturerops/viewcourse.dart';

class TeacherHome extends StatefulWidget {
  TeacherHome();
  @override
  _TeacherHomeState createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  void initState() {
    Firebase.initializeApp();
    super.initState();
    //getCurrentUser();
  }

  String? email;
  String? password;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  title(),
                ],
              ),
              Text(
                "Hoş Geldiniz,\n" + _auth.currentUser!.displayName!,
                style: TextStyle(
                    color: Colors.black87.withOpacity(0.8),
                    fontSize: 25,
                    fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                    onPressed: () async {
                      Route route =
                          MaterialPageRoute(builder: (context) => Students());
                      Navigator.push(context, route);
                    },
                    child: Text(
                      'Öğrenciler',
                      style: TextStyle(color: Consts.mainColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Route route =
                          MaterialPageRoute(builder: (context) => AddCourse());
                      Navigator.push(context, route);
                    },
                    child: Text('Ders Ekle',
                        style: TextStyle(color: Consts.mainColor)),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dersler\n",
                    style: TextStyle(
                        color: Colors.black87.withOpacity(0.8),
                        fontSize: 30,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('teachers')
                    .doc(_auth.currentUser!.email)
                    .collection("courses")
                    .snapshots(),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? snapshot.data!.docs.isEmpty
                          ? Container(
                              height: 150,
                              child: Center(
                                child: Text(
                                  'Ders bulunmuyor.',
                                  style: TextStyle(
                                      color: Colors.black87.withOpacity(0.8),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Route route = MaterialPageRoute(
                                          builder: (context) => CourseInfo(
                                              data:
                                                  snapshot.data!.docs[index]));
                                      Navigator.push(context, route);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(snapshot.data!.docs[index]
                                                ['code']),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(snapshot.data!.docs[index]
                                                ['name']),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(snapshot.data!.docs[index]
                                                ['semester']),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })
                      : Center(
                          child: CupertinoActivityIndicator(),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
