import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:Face_recognition/widgets/dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import '../../utils/detector_painters.dart';
import '../../utils/utils.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:quiver/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class DoAttendance extends StatefulWidget {
  DoAttendance(
      {required this.courseData, required this.week, required this.code});
  dynamic courseData;
  String week;
  String code;
  @override
  DoAttendanceState createState() => DoAttendanceState();
}

class DoAttendanceState extends State<DoAttendance> {
  File? jsonFile;
  dynamic _scanResults;
  CameraController? _camera;

  var interpreter;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  dynamic data = {};
  double threshold = 1.0;
  Directory? tempDir;
  List? e1;
  bool _faceFound = false;

  List<dynamic> exists = [];
  List<dynamic> notExists = [];

  final TextEditingController _name = new TextEditingController();
  @override
  void initState() {
    super.initState();
    print("COURSEDATA" + widget.courseData.toString());

    notExists = widget.courseData;

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _initializeCamera();
  }

  Future loadModel() async {
    print("load");
    try {
      final gpuDelegateV2 = tfl.GpuDelegateV2(
        options: tfl.GpuDelegateOptionsV2(),
        // options: tfl.GpuDelegateOptionsV2(
        //   false,
        //   tfl.TfLiteGpuInferenceUsage.fastSingleAnswer,
        //   tfl.TfLiteGpuInferencePriority.minLatency,
        //   tfl.TfLiteGpuInferencePriority.auto,
        //   tfl.TfLiteGpuInferencePriority.auto,
        // ),
      );

      var interpreterOptions = tfl.InterpreterOptions()
        ..addDelegate(gpuDelegateV2);
      interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
    } on Exception {
      print('Failed to load model.');
    }
  }

  void _initializeCamera() async {
    await loadModel();
    CameraDescription description = await getCamera(_direction);

    InputImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera = CameraController(description, ResolutionPreset.high,
        enableAudio: false);
    //    _camera =
    //    CameraController(description, ResolutionPreset.max, enableAudio: false);
    await _camera!.initialize();
    await Future.delayed(Duration(milliseconds: 100));
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir!.path + '/emb.json';
    jsonFile = new File(_embPath);
    if (jsonFile!.existsSync())
      data = json.decode(jsonFile!.readAsStringSync());

    _camera!.startImageStream((CameraImage image) {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        String res;
        dynamic finalResult = Multimap<String, Face>();
        detect(image, _getDetectionMethod(), rotation).then(
          (dynamic result) async {
            if (result.length == 0)
              _faceFound = false;
            else
              _faceFound = true;
            Face _face;
            imglib.Image convertedImage =
                _convertCameraImage(image, _direction);
            for (_face in result) {
              double x, y, w, h;
              x = (_face.boundingBox.left - 10);
              y = (_face.boundingBox.top - 10);
              w = (_face.boundingBox.width + 10);
              h = (_face.boundingBox.height + 10);
              imglib.Image croppedImage = imglib.copyCrop(
                  convertedImage, x.round(), y.round(), w.round(), h.round());
              croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
              // int startTime = new DateTime.now().millisecondsSinceEpoch;
              res = _recog(croppedImage);
              // int endTime = new DateTime.now().millisecondsSinceEpoch;
              // print("Inference took ${endTime - startTime}ms");
              finalResult.add(res, _face);
            }
            setState(() {
              _scanResults = finalResult;
            });

            _isDetecting = false;
          },
        ).catchError(
          (_) {
            print("error");
            _isDetecting = false;
          },
        );
      }
    });
  }

  HandleDetection _getDetectionMethod() {
    final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
    return faceDetector.processImage;
  }

  Widget _buildResults() {
    const Text noResultsText = const Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    if (_camera == null || !_camera!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      //constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera!),
                _buildResults(),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _camera!.stopImageStream();
    await _camera!.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  final _auth = FirebaseAuth.instance;

  User? loggedInUser;

  createData() async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('teachers')
        .doc(_auth.currentUser!.email)
        .collection("courses")
        .doc(widget.code)
        .collection("weeks")
        .doc(widget.week);

    Map<String, dynamic> dish = {
      "attended": exists,
      "unattended": notExists,
    };

    documentReference.update(dish).whenComplete(() {
      print(' created');
    });
    await _camera!.stopImageStream();
    await _camera!.dispose();
    Navigator.pop(context);
    openAlertBox(context, "Yoklama Alındı", "Yoklama başarıyla alındı");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        title: Row(
          children: [
            Text(
              'Katılan: ${exists.length}',
              style: TextStyle(color: Colors.green),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Katılmayan:${notExists.length}',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text('Bitir'),
            onPressed: () {
              createData();
            },
          ),
        ],
      ),
      body: _buildImage(),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          onPressed: _toggleCameraDirection,
          heroTag: null,
          child: _direction == CameraLensDirection.back
              ? const Icon(Icons.camera_front)
              : const Icon(Icons.camera_rear),
        ),
      ]),
    );
  }

  imglib.Image _convertCameraImage(
      CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)
        ? imglib.copyRotate(img, -90)
        : imglib.copyRotate(img, 90);
    return img1;
  }

  String _recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);

    for (int i = 0; i < widget.courseData.length; i++) {
      if (widget.courseData[i]["nameSurname"] == compare(e1!)) {
        if (!exists.contains(widget.courseData[i]["nameSurname"])) {
          exists.add(widget.courseData[i]);
          notExists.remove(widget.courseData[i]);
        }
      }
    }
    setState(() {
      exists;
      notExists;
    });

    print("HEYEXISTS" + exists.toString());
    print("HEYNOTEXISTS" + notExists.toString());

    return compare(e1!).toUpperCase();
  }

  String compare(List currEmb) {
    if (data.length == 0) return "Öğrenci kayıt edilmedi";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "Tanınmadı";
    for (String label in data.keys) {
      print(data);
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }

    print(minDist.toString() + " " + predRes);

    return predRes;
  }

  void _resetFile() {
    data = {};
    jsonFile!.deleteSync();
  }

  void _viewLabels() {
    setState(() {
      _camera = null;
    });
    String name;
    var alert = AlertDialog(
      title: new Text("Saved Faces"),
      content: Container(
        height: 300.0, // Change as per your requirement
        width: 300.0,
        child: new ListView.builder(
            shrinkWrap: true,
            padding: new EdgeInsets.all(2),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              name = data.keys.elementAt(index);
              return new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      name,
                      style: new TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.all(2),
                  ),
                  new Divider(),
                ],
              );
            }),
      ),
      actions: <Widget>[
        new MaterialButton(
          child: Text("OK"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void _addLabel() {
    setState(() {
      _camera = null;
    });
    print("Adding new face");
    var alert = new AlertDialog(
      title: new Text("Add Face"),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: new TextField(
              controller: _name,
              autofocus: true,
              decoration: new InputDecoration(
                  labelText: "Name", icon: new Icon(Icons.face)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new MaterialButton(
            child: Text("Save"),
            onPressed: () {
              _handle(_name.text.toUpperCase());
              _name.clear();
              Navigator.pop(context);
            }),
        new MaterialButton(
          child: Text("Cancel"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void _handle(String text) {
    data[text] = e1;
    jsonFile!.writeAsStringSync(json.encode(data));
    _initializeCamera();
  }
}
