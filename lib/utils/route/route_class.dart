
import 'package:flutter/material.dart';
import 'package:google_map_live_tracking/screens/home_screen.dart';

import '../../screens/show_tracked_screen.dart';
import '../../splash_screen.dart';
import '../../widgets/custom_widgets/custom_page_route.dart';

class RouteClass{
  static Route onGenerateRoute(RouteSettings settings){
    // print("test....route...........");
    switch(settings.name){
      case SplashScreen.route:
        return CustomPageRoute(
          child: const SplashScreen(),
          settings: settings,
        );
      case HomeScreen.route:
        return CustomPageRoute(
          child:  const HomeScreen(),
          settings: settings,
        );
      case ShowTrackedScreen.route:
        return CustomPageRoute(
          child:  const ShowTrackedScreen(),
          settings: settings,
        );
      default:
        return CustomPageRoute(
          child:  const Placeholder(
            strokeWidth: 0,
            child: Center(
              child: Text("No Route Found"),
            ),
          ),
          settings: settings,
        );
    }
  }
}