import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

import 'homPage.dart';

class MySplashScreen extends StatefulWidget {
  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 4,
      navigateAfterSeconds: HomePage(),
      title: Text(
        "Face Detection",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      image: Image.asset("assets/face.jpg"),
      photoSize: 130,
      backgroundColor: Colors.white,
      loaderColor: Colors.black,
      loadingText: Text(
        "nanlambda.com",style: TextStyle(color: Colors.black,fontSize: 16.0),

      ),
    );
  }
}
