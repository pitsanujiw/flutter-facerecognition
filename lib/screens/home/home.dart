import 'dart:io';

import 'package:facedetector/constants/constants.dart';
import 'package:facedetector/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  static const ROUTE_NAME = RouteConstant.HOME;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: new RenderHome(),
    );
  }
}

class RenderHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeWidget();
}

class HomeWidget extends State<RenderHome> {
  File jsonFile;
  @override
  void initState() {
    super.initState();
  }

  Future<void> getAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool('Is_Authen');
  }

  Future<void> getFile() async {
    jsonFile = await getFileModel();
  }

  void delete() async {
    await jsonFile.delete();
  }

  @override
  Widget build(BuildContext context) {
    return (new Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: new Center(
          child: new ButtonBar(
        children: [
          RaisedButton(
            onPressed: () {
              delete();
            },
            child: Text('Delete'),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteConstant.LOGIN);
            },
            child: Text('Login'),
          )
        ],
      )),
    )));
  }
}
