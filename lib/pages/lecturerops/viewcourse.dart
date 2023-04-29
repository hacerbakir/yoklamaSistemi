import 'package:Face_recognition/pages/lecturerops/addface.dart';
import 'package:Face_recognition/pages/lecturerops/doattendance.dart';
import 'package:Face_recognition/pages/auth/register.dart';
import 'package:Face_recognition/pages/lecturerops/addcourse.dart';
import 'package:Face_recognition/pages/lecturerops/addweek.dart';
import 'package:Face_recognition/pages/lecturerops/weekdetail.dart';
import 'package:Face_recognition/utils/consts.dart';
import 'package:Face_recognition/widgets/button.dart';
import 'package:Face_recognition/widgets/dialog.dart';
import 'package:Face_recognition/widgets/title.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseInfo extends StatefulWidget {
  CourseInfo({required this.data});
  dynamic data;
  @override
  _CourseInfoState createState() => _CourseInfoState();
}

class _CourseInfoState extends State<CourseInfo> {
  void initState() {
    Firebase.initializeApp();
    super.initState();
    //getCurrentUser();
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
    Navigator.pop(context);
    openAlertBox(context, "title", "Öğrenci eklendi");
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
              SizedBox(
                height: 10,
              ),
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
                      Text(
                        widget.data['name'],
                        style: TextStyle(
                            color: Colors.black87.withOpacity(0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.data['semester'],
                        style: TextStyle(
                            color: Colors.black87.withOpacity(0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Öğrenci Listesi'),
                              content: setupAlertDialoadContainer(),
                            );
                          });
                    },
                    child: Text(
                      'Öğrenci Ekle',
                      style: TextStyle(color: Consts.mainColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Route route = MaterialPageRoute(
                          builder: (context) =>
                              AddWeek(code: widget.data['code']));
                      Navigator.push(context, route);
                    },
                    child: Text(
                      'Hafta Ekle',
                      style: TextStyle(color: Consts.mainColor),
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('teachers')
                    .doc(_auth.currentUser!.email)
                    .collection("courses")
                    .doc(widget.data['code'])
                    .collection('weeks')
                    .snapshots(),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? snapshot.data!.docs.isEmpty
                          ? Container(
                              height: 400,
                              child: Center(
                                child: Text(
                                  'Hafta ekleyiniz',
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
                                        if ((snapshot.data!.docs[index].data()
                                                as Map<String, dynamic>)
                                            .containsKey('attended')) {
                                          Route route = MaterialPageRoute(
                                              builder: (context) => WeekInfo(
                                                  data: widget.data,
                                                  week: snapshot
                                                      .data!.docs[index]));
                                          Navigator.push(context, route);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Hafta: " +
                                                    snapshot.data!.docs[index]
                                                        ['no']),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text("Tarih: " +
                                                    snapshot.data!.docs[index]
                                                        ['date']),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text("Saat: " +
                                                    snapshot.data!.docs[index]
                                                        ['time']),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    (snapshot.data!.docs[index]
                                                                    .data()
                                                                as Map<String,
                                                                    dynamic>)
                                                            .containsKey(
                                                                'attended')
                                                        ? Text(
                                                            "Katılan: " +
                                                                snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                        [
                                                                        'attended']
                                                                    .length
                                                                    .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          )
                                                        : SizedBox(),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    (snapshot.data!.docs[index]
                                                                    .data()
                                                                as Map<String,
                                                                    dynamic>)
                                                            .containsKey(
                                                                'unattended')
                                                        ? Text(
                                                            "Katılmayan: " +
                                                                snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                        [
                                                                        'unattended']
                                                                    .length
                                                                    .toString(),
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          )
                                                        : SizedBox(),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                            customButton(() async {
                                              CollectionReference
                                                  courseStudentRef =
                                                  FirebaseFirestore.instance
                                                      .collection('teachers')
                                                      .doc(_auth
                                                          .currentUser!.email!)
                                                      .collection('courses')
                                                      .doc(widget.data['code'])
                                                      .collection(
                                                          'coursestudents');

                                              QuerySnapshot querySnapshot =
                                                  await courseStudentRef.get();

                                              final allData = querySnapshot.docs
                                                  .map((doc) => doc.data())
                                                  .toList();

                                              Route route = MaterialPageRoute(
                                                  builder: (context) =>
                                                      DoAttendance(
                                                          code: widget
                                                              .data['code'],
                                                          courseData: allData,
                                                          week: snapshot.data!
                                                                  .docs[index]
                                                              ['date']));
                                              Navigator.push(context, route);
                                            },
                                                "Yoklama Al",
                                                Icon(Icons.check,
                                                    color: Colors.white)),
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
