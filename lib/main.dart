import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_map_live_tracking/providers/home_provider.dart';
import 'package:google_map_live_tracking/screens/home_screen.dart';
import 'package:google_map_live_tracking/splash_screen.dart';
import 'package:google_map_live_tracking/utils/global_classes/local_notification_service.dart';
import 'package:google_map_live_tracking/utils/global_classes/navigation_service_without_context.dart';
import 'package:google_map_live_tracking/utils/route/route_class.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();;
  await initializeService();
  LocalNotificationService().initNotification();

  final providerList =  [
  ChangeNotifierProvider(create: (context) => HomeProvider()),
  ];
  runApp(
    MultiProvider(
      providers: providerList,
      child: const MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: NavigationService.navigatorKey,
      home: const SplashScreen(),
      onGenerateRoute: (route)=> RouteClass.onGenerateRoute(route),
    );
  }


}


