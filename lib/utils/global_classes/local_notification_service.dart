import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';


class LocalNotificationService {
  String channelName = "notification-channel";

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  //static final onNotificationStream = BehaviorSubject<dynamic>();

  Future<void> initNotification() async {
    //listenNotification();
    //android/app/src/main/res/mipmap-hdpi(mipmap/ic_launcher.png)
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (int id, String? title, String? body, dynamic payload) async {});

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
          //onNotificationStream.add(notificationResponse.payload);
         // Navigator.of(NavigationService.navigatorKey.currentState!.context).push(MaterialPageRoute(builder: (context) => NotificationScreen(payload: notificationResponse.payload,)));
          //Navigator.of(NavigationService.navigatorKey.currentState!.context).pushNamedAndRemoveUntil(NotificationScreen.route, (route) => false);
         // Navigator.of(NavigationService.navigatorKey.currentState!.context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => NotificationScreen(payload: notificationResponse.payload,)), (route) => false);
        //  Navigator.of(NavigationService.navigatorKey.currentState!.context).popUntil((route) => false);
         // Navigator.of(NavigationService.navigatorKey.currentState!.context).po
          // Navigator.of(NavigationService.navigatorKey.currentState!.context).popUntil((route) {
          //   // Replace '/target_screen' with the name of the route you want to navigate to.
          //   return route.settings.name == '/NotificationScreen';
          // });
        //  Navigator.popUntil(NavigationService.navigatorKey.currentState!.context, (Route<dynamic> route) => route.isFirst);

          //this for showing in data in notification screen
         // Navigator.popUntil(NavigationService.navigatorKey.currentState!.context, ModalRoute.withName(route));
          //Navigator.of(NavigationService.navigatorKey.currentState!.context).push(MaterialPageRoute(builder: (context) => RealtimeNotificationScreen(payload: notificationResponse.payload,)));
          },
    );
  }

  notificationDetails() {
   // print("tes.........1");
   // listenNotification();
    return  NotificationDetails(
        android: AndroidNotificationDetails('channelId', channelName, importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  //this function is called from push notification function
  Future showNotification(
      {int id = 0, String? title, required String? body, var payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails(), payload: payLoad);
  }

 // void listenNotification() => LocalNotificationService.onNotificationStream.stream.listen(onClickedNotification);
  // void onClickedNotification(String? payload) => Navigator.pushNamed(context, NotificationScreen.route);
  void onClickedNotification(dynamic payload){
   // Navigator.of(NavigationService.navigatorKey.currentState!.context).pop();
  //  Navigator.of(NavigationService.navigatorKey.currentState!.context).push(MaterialPageRoute(builder: (context) => RealtimeNotificationScreen(payload: payload,)));
  }


}