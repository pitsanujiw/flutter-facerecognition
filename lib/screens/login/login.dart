import 'package:facedetector/constants/constants.dart';
import 'package:facedetector/widgets/widgets.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  static const ROUTE_NAME = RouteConstant.LOGIN;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: new Stack(
        children: [
          RenderFaceDetect(),
          RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteConstant.SIGNUP);
            },
            child: Text('sign up'),
          ),
        ],
      )),
    );
  }
}
