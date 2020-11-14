import 'package:facedetector/screens/screens.dart';
import 'package:flutter/material.dart';

class AppRoute extends NavigatorObserver {
  AppRoute._internal();
  static final AppRoute _appRoute = AppRoute._internal();
  factory AppRoute() => _appRoute;

  static final Map<String, WidgetBuilder> _routes = {
    HomePage.ROUTE_NAME: (_) => HomePage(),
    LoginPage.ROUTE_NAME: (_) => LoginPage(),
    SignUpPage.ROUTE_NAME: (_) => SignUpPage(),
  };
  Map<String, WidgetBuilder> get routes => _routes;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    MaterialPageRoute targetPage;

    if (settings.name == HomePage.ROUTE_NAME) {
      targetPage = MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return HomePage();
        },
      );
    }

    return targetPage ??
        MaterialPageRoute(builder: (context) {
          return Text('');
        });

    // unknown route
  }
}

AppRoute appRoute = AppRoute();
