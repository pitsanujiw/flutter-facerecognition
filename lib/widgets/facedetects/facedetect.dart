import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:facedetector/utils/utils.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class RenderFaceDetect extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FaceDetect();
}

class FaceDetect extends State<RenderFaceDetect> {
  CameraController _camera;
  CameraLensDirection _direction = CameraLensDirection.front;
  Interpreter interpreter;
  Directory tempDir;
  ImageRotation rotation;
  dynamic data = {};
  File jsonFile;
  List e1;
  bool _scanResults = false;
  bool _isDetecting = false;
  bool faceFound = false;
  double threshold = 1.0;
  double minDist = 999;
  double currDist = 0.0;
  BuildContext contextDialog;
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

    _camera =
        CameraController(description, ResolutionPreset.low, enableAudio: false);
    await _camera.initialize();
    jsonFile = await getFileModel();
    if (jsonFile.existsSync()) data = json.decode(jsonFile.readAsStringSync());

    if (_camera != null) {
      Future.delayed(Duration(milliseconds: 500)).then((_) async {
        dialogScanner();
      });
      await _streamCamera();
    }
  }

  Future _streamCamera() async {
    await Future.delayed(Duration(microseconds: 500));

    _camera.startImageStream((CameraImage image) async {
      if (_camera != null) {
        if (_isDetecting) return;
        setState(() {
          _isDetecting = true;
        });
        try {
          await vaildateImage(image);
        } catch (_) {
          setState(() {
            _isDetecting = false;
          });
        }
      }
    });
  }

  Future vaildateImage(CameraImage image) async {
    try {
      var result = await detect(image, detection, rotation);
      if (result.length == 0)
        setState(() {
          faceFound = false;
        });
      else
        setState(() {
          faceFound = true;
        });
      Face _face;
      imglib.Image convertedImage = convertCameraImage(image, _direction);
      for (_face in result) {
        imglib.Image croppedImage = croppingImage(_face, convertedImage);
        List picEncode = recogImage(croppedImage, interpreter);
        _scanResults = compare(picEncode);
        if (_scanResults) {
          Navigator.pop(contextDialog);
          Future.delayed(Duration(seconds: 1)).then((_) async {
            Navigator.pushNamed(context, '/home');
          });
        } else {
          _isDetecting = false;
        }
      }
    } catch (_) {
      _isDetecting = false;
    }
  }

  bool compare(List currEmb) {
    if (data.length == 0) return false;
    bool isDetect = false;
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        isDetect = true;
        break;
      }
    }
    return isDetect;
  }

  Future<Widget> dialogScanner() {
    var modalBottomSheet = showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      builder: (BuildContext context) {
        contextDialog = context;
        return Container(
          height: 350,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Face Detection',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Icon(
                  Icons.face,
                  color: _scanResults ? Colors.lightBlue : Colors.black,
                  size: 150,
                  semanticLabel: '',
                ),
              ],
            ),
          ),
        );
      },
    );

    return modalBottomSheet;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black87,
      body: new Container(
          child: CircularProgressIndicator(
        backgroundColor: Colors.white,
      )),
    );
  }
}
