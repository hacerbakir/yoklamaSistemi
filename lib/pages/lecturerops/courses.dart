import 'package:Face_recognition/pages/lecturerops/addface.dart';
import 'package:Face_recognition/pages/auth/register.dart';
import 'package:Face_recognition/pages/lecturerops/addcourse.dart';
import 'package:Face_recognition/pages/lecturerops/viewcourse.dart';
import 'package:Face_recognition/widgets/title.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Courses extends StatefulWidget {
  Courses();
  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
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
              title(),
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('teachers')
                      .doc(_auth.currentUser!.email)
                      .collection("courses")
                      .snapshots(),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? ListView.builder(
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
                                            data: snapshot.data!.docs[index]));
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
