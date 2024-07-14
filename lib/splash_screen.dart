import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_map_live_tracking/screens/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static const String route = "/SplashScreen";
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer() {
    Timer(const Duration(seconds: 2), () async {
      // SharedPreferences sh = await SharedPreferences.getInstance();
      // Map<Permission, PermissionStatus> statuses = await [Permission.notification, Permission.camera, Permission.storage, Permission.location].request();
      // if(statuses[Permission.camera] == PermissionStatus.granted && statuses[Permission.location] == PermissionStatus.granted){
      // }else{
      //   return;
      // }
      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.route, (route) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(child: Icon(Icons.add_a_photo_outlined)),
    );
  }
}
