import 'package:facedetector/constants/constants.dart';
import 'package:facedetector/widgets/facearchive/facearchive.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  static const ROUTE_NAME = RouteConstant.SIGNUP;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Text('SIGN UP')),
        preferredSize: new AppBar().preferredSize,
      ),
      body: Container(child: RenderFaceArchive()),
    );
  }
}
