import 'package:Face_recognition/pages/lecturerops/addface.dart';
import 'package:Face_recognition/pages/lecturerops/doattendance.dart';
import 'package:Face_recognition/pages/auth/register.dart';
import 'package:Face_recognition/pages/lecturerops/addcourse.dart';
import 'package:Face_recognition/pages/lecturerops/addweek.dart';
import 'package:Face_recognition/widgets/button.dart';
import 'package:Face_recognition/widgets/title.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeekInfo extends StatefulWidget {
  WeekInfo({required this.data, required this.week});
  dynamic data;
  dynamic week;

  @override
  _WeekInfoState createState() => _WeekInfoState();
}

class _WeekInfoState extends State<WeekInfo> {
  void initState() {
    super.initState();
  }

  String? email;
  String? password;
  final _auth = FirebaseAuth.instance;

  User? loggedInUser;

  void addStudentToCourse(
      String studentnumber, Map<String, dynamic> dish) async {
    createData(String userid) {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('teachers')
          .doc(userid)
          .collection('courses')
          .doc(widget.data['code'])
          .collection('coursestudents')
          .doc(studentnumber);

      documentReference.set(dish).whenComplete(() {
        print(' created');
      });
    }

    createData(_auth.currentUser!.email!);
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      height: 600.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
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
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            Map<String, dynamic> dish = {
                              "nameSurname": snapshot.data!.docs[index]
                                  ['nameSurname'],
                              "no": snapshot.data!.docs[index]['no'],
                              "email": snapshot.data!.docs[index]['email'],
                            };
                            addStudentToCourse(
                                snapshot.data!.docs[index]['no'], dish);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot.data!.docs[index]['nameSurname']),
                                Text(snapshot.data!.docs[index]['email']),
                                Text(snapshot.data!.docs[index]['no']),
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
    );
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
              title(),
            
             
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data['code'],
                        style: TextStyle(
                            color: Colors.black87.withOpacity(0.8),
                            fontSize: 30,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.data['name'],
                        style: TextStyle(
                            color: Colors.black87.withOpacity(0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Hafta: " +
                            widget.week["no"] +
                            " Tarih: " +
                            widget.week["date"],
                        style: TextStyle(
                            color: Colors.black87.withOpacity(0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Katılanlar",
                style: TextStyle(
                    color: Colors.green.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.week["attended"].length,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.week["attended"][index]
                                      ["nameSurname"]),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(widget.week["attended"][index]["no"]),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(widget.week["attended"][index]["email"]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              SizedBox(
                height: 10,
              ),
              Text(
                "Katılmayanlar",
                style: TextStyle(
                    color: Colors.red.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.week["unattended"].length,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.week["unattended"][index]
                                      ["nameSurname"]),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(widget.week["unattended"][index]["no"]),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(widget.week["unattended"][index]
                                      ["email"]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })

/*

              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('teachers')
                      .doc(_auth.currentUser!.email)
                      .collection("courses")
                      .doc(widget.data['code'])
                      .collection('coursestudents')
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
                                            ['email']),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(snapshot.data!.docs[index]
                                            ['nameSurname']),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(snapshot.data!.docs[index]['no']),
                                      ],
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
*/
            ],
          ),
        ),
      ),
    );
  }
}
