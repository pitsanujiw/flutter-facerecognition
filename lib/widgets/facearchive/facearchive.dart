import 'dart:convert';
import 'dart:io';
import 'package:facedetector/utils/utils.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

class RenderFaceArchive extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FaceArchive();
}

class FaceArchive extends State<RenderFaceArchive> {
  CameraController _camera;
  CameraLensDirection _direction = CameraLensDirection.front;
  Interpreter interpreter;
  ImageRotation rotation;
  dynamic data = {};
  File jsonFile;
  List e1;
  bool _isDetecting = false;
  bool faceFound = false;
  int _countFace = 0;
  double threshold = 1.0;
  double minDist = 999;
  bool _isFinish = false;
  double currDist = 0.0;
  HandleDetection detection;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _camera.dispose();
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<void> deactivate() async {
    super.deactivate();
    _camera.dispose();
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future _initializeModel() async {
    try {
      interpreter = await loadModel();
    } catch (e) {
      throw e;
    }
  }

  Future _getDetection() async {
    detection = getDetectionMethod();
  }

  void _initializeCamera() async {
    await _initializeModel();
    await _getDetection();
    CameraDescription description = await getCamera(_direction);
    rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera = CameraController(description, ResolutionPreset.veryHigh,
        enableAudio: false);
    await _camera.initialize();
    await Future.delayed(Duration(milliseconds: 500));
    jsonFile = await getFileModel();
    if (jsonFile.existsSync()) data = json.decode(jsonFile.readAsStringSync());

    if (_camera != null) {
      await _streamCamera();
    }
  }

  Future _streamCamera() async {
    _camera.startImageStream((CameraImage image) async {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        detect(image, detection, rotation).then(
          (dynamic result) async {
            if (result.length == 0) {
              setState(() {
                faceFound = false;
                _isDetecting = false;
              });
            } else {
              setState(() {
                faceFound = true;
              });
              imglib.Image convertedImage =
                  convertCameraImage(image, _direction);
              for (Face _face in result) {
                _countFace += 1;
                if (_countFace >= 20) {
                  setState(() {
                    _isDetecting = true;
                    _isFinish = true;
                    _camera.stopImageStream();
                  });
                  return;
                }

                imglib.Image croppedImage =
                    croppingImage(_face, convertedImage);
                List picEncode = recogImage(croppedImage, interpreter);
                saveFaceRecognition(picEncode);
                _isDetecting = false;
              }
            }
          },
        ).catchError(
          (_) {
            _isDetecting = false;
          },
        );
      }
    });
  }

  Future processImages(CameraImage image) async {
    try {
      dynamic result = await detect(image, detection, rotation);
      if (result.length == 0) {
        setState(() {
          faceFound = false;
          _isDetecting = false;
        });
      } else {
        setState(() {
          faceFound = true;
        });
        imglib.Image convertedImage = convertCameraImage(image, _direction);
        for (Face _face in result) {
          _countFace += 1;
          if (_countFace >= 20) {
            setState(() {
              _isDetecting = true;
              _isFinish = true;
              _camera.stopImageStream();
            });
            return;
          }

          imglib.Image croppedImage = croppingImage(_face, convertedImage);
          List picEncode = recogImage(croppedImage, interpreter);
          saveFaceRecognition(picEncode);
          _isDetecting = false;
        }
      }
    } catch (e) {}
  }

  void saveFaceRecognition(e1) {
    data[genId()] = e1;
    jsonFile.writeAsStringSync(json.encode(data));
  }

  Widget buttonNav() {
    return _isFinish
        ? new Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              onPressed: () {
                setState(() {
                  Navigator.pushNamed(context, '/home');
                });
              },
              child: const Text('Confirm', style: TextStyle(fontSize: 20)),
              color: Colors.blue,
              textColor: Colors.white,
              elevation: 5,
            ),
          )
        : new Text(
            'Position you face inside the circle',
            style: TextStyle(color: Colors.white),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (_camera == null || !_camera.value.isInitialized)
      return new Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
      );

    return new Scaffold(
        backgroundColor: Colors.black87,
        body: Container(
          width: 800,
          child: _isFinish ? showCamera() : finishDetect(),
        ));
  }

  Widget showCamera() {
    return new Stack(children: [
      Container(
        alignment: Alignment(0, -0.2),
        child: Icon(
          Icons.face,
          color: Colors.white,
          size: 150,
          semanticLabel: '',
        ),
      ),
      buttonNav(),
    ]);
  }

  Widget finishDetect() {
    return new Stack(
      children: <Widget>[
        Container(
            alignment: Alignment(0, -0.6),
            child: Text(
              'Position you face inside the circle',
              style: TextStyle(color: Colors.white, fontSize: 25),
            )),
        Center(
            child: ClipOval(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 0.37,
            widthFactor: 0.67,
            child: !_isFinish
                ? CameraPreview(_camera)
                : Text(
                    'STOP',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        )),
      ],
    );
  }
}
