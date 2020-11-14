import 'package:facedetector/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:facedetector/routes/routes.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: appRoute.routes,
      onGenerateRoute: appRoute.onGenerateRoute,
      navigatorObservers: [
        appRoute,
      ],
      title: 'Face Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var scaffold = Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: PreferredSize(
//           child: AppBar(
//             title: Text(widget.title),
//             backgroundColor: Colors.transparent,
//             elevation: 0.0,
//           ),
//           preferredSize: new AppBar().preferredSize,
//         ),
//         body: Center(
//           child: HomePage(),
//         ));
//     return scaffold;
//   }
// }
