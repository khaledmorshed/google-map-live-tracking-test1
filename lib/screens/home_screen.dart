import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geoLoc;
import 'package:geolocator/geolocator.dart';
import 'package:google_map_live_tracking/screens/show_tracked_screen.dart';
import 'package:google_map_live_tracking/utils/app_config.dart';
import 'package:google_map_live_tracking/widgets/custom_widgets/custom_elevated_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/local/sqflite/sqf_lite_db.dart';
import '../utils/global_classes/call_class.dart';
import '../utils/global_classes/color_manager.dart';
import '../utils/global_classes/debounce_class.dart';
import '../utils/global_variable.dart';
import '../widgets/custom_widgets/custom_text_form_field.dart';

// fetch location for updating
Future<loc.LocationData> fetchCurrentLocationWithLocationPackageForBackground() async {
  try {
    bool serviceEnabled;
    loc.PermissionStatus permissionStatus;
    final locationController = loc.Location();

    // Check if location service is enabled
    serviceEnabled = await locationController.serviceEnabled();
    if (serviceEnabled) {

      // Request to enable location service
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    // Check the permission status
    permissionStatus = await locationController.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      // Request location permission
      permissionStatus = await locationController.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        return Future.error('Location permissions are denied.');
      }
    }

    // Get the current location
    return await locationController.getLocation();
  } catch (err) {
    print("Error: $err");
    return Future.error(err);
  }
}

// this will be used as notification channel id
const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
   //   onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print("test...1");
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  print("test...2");

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  print("test...3");
  await preferences.setString("hello", "world");
  print("test...4");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  print("test...5");

  if (service is AndroidServiceInstance) {
    print("test...6");
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    print("test...7");

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
    print("test...8");
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  print("test...9");

  // bring to foreground
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        print("test...11");
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // // if you don't using custom notification, uncomment this
        // service.setForegroundNotificationInfo(
        //   title: "My App Service",
        //   content: "Updated at ${DateTime.now()}",
        // );
        dynamic locationData;
        try{
          print("test...12");
          if(CallClass.isNowCall)locationData = await fetchCurrentLocationWithLocationPackageForBackground();
          print("latalongdta....${locationData}");
          service.setForegroundNotificationInfo(
            title: "My App Service",
            content: "lat=${locationData.latitude}, long=${locationData.longitude}",
          );

        }catch(err){
          print("backError...$err");

          service.setForegroundNotificationInfo(
            title: "My App Service",
            content: "Error: ${DateTime.now()}",
          );

          // service.setForegroundNotificationInfo(
          //   title: "My App Service",
          //   content: "lat=${locationData.latitude}, long=${locationData.longitude}",
          // );

        }
      }
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}
//end for background

class HomeScreen extends StatefulWidget {
  static const String route = "/HomeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static LatLng destination = LatLng(23.7568, 90.3901);
  static LatLng originLocation = LatLng(23.7220, 90.4214);
  final Completer<GoogleMapController> completerController = Completer();

  LatLng? currentPosition;

  dynamic destinationLatLongPosition;
  Map<PolylineId, Polyline> polyLinesMap = {};
  List<PointLatLng> waypoints = [];
  final changeLatTextEditingController = TextEditingController();
  final changeLongTextEditingController = TextEditingController();
  String movingMood = "drive";
  BitmapDescriptor originIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;
  bool isUpdateCurrentLocation = false;
  bool isTwoPointSame = false;
  Map<MarkerId, Marker> markers = {};
  bool isConfirmOrigin = false;
  bool isConfirmDestination = false;

  final startLocationController = TextEditingController();
  final destinationController = TextEditingController();

  StreamSubscription<Position>? positionStreamSubscription;
  String currentAddress = "";
  var logger = Logger();
  List<dynamic> originSearchResults = [];
  List<dynamic> destinationSearchResults = [];
  String originPlaceId = "";
  String destinationPlaceId = "";
  bool isNeedToRedraw = false;
  double _initialChildSize = 0.3;
  double _maxChildSize = 1.0;
  late  VoidCallback _debouncedCallDataForStartingLocation;
  late  VoidCallback _debouncedCallDataForDestination;
  bool isDestinationField = false;
  final DraggableScrollableController _draggableScrollableController = DraggableScrollableController();

  final locationController = loc.Location();
  StreamSubscription<loc.LocationData>? locationSubscription;
  List<LatLng> originalRoutePoints = [];



  void _onTextChangedForStartingLocation(String text) {
    // Call the debounce function to handle the delayed data call
    _debouncedCallDataForStartingLocation();
  }

  void _callDataForStartingLocation() {
    searchLocations(startLocationController.text);
  }

  //search for starting
  Widget _buildSearchForStartingLocation(ScrollController controller){

    return  SingleChildScrollView(
        controller: controller,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomTextFormField(
          controller: startLocationController,
          //labelText: "Name",
          hintText: "Starting location",
          fillColor: ColorManager.homeBg,
          iconColor: ColorManager.buttonColorBlue ,
          focusBoarderColor: ColorManager.homeBg,
          enabledBoarderColor: ColorManager.homeBg,
          isFilled: true,
          isContentPadding: true,
          contentPaddingHorizontal: 15,
          contentPaddingVertical: 8,
          onChanged: (value){
            setState(() {
              isDestinationField = false;
            });
            return _onTextChangedForStartingLocation(value);
            },
          onTap: ()async{
            await setBottomSheetSizeAfterclickOnTextField();
            setState(() {
              print("ontap...start");
              isDestinationField = false;
              originSearchResults = [];
            });
          },
        ),
      ),
    );
  }

  void _onTextChangedForDestination(String text) {
    // Call the debounce function to handle the delayed data call
    _debouncedCallDataForDestination();
  }

  void _callDataForDestination() {
    searchLocations(destinationController.text);
  }

  //search for destination
  Widget _buildSearchForDestination(ScrollController controller){
    return  SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomTextFormField(
          controller: destinationController,
          //labelText: "Name",
          hintText: "Destination",
          fillColor: ColorManager.homeBg,
          iconColor: ColorManager.buttonColorBlue ,
          focusBoarderColor: ColorManager.homeBg,
          enabledBoarderColor: ColorManager.homeBg,
          isFilled: true,
          isContentPadding: true,
          contentPaddingHorizontal: 15,
          contentPaddingVertical: 8,
          onChanged: (value){
            setState(() {
              isDestinationField = true;
            });
            return _onTextChangedForDestination(value);
          },
          onTap: ()async{
            await setBottomSheetSizeAfterclickOnTextField();
            setState(() {
              print("ontap...dest");
              isDestinationField = true;
              originSearchResults = [];
            });
          },
        ),
      ),
    );
  }

  Future<void> setBottomSheetSizeAfterclickOnTextField()async{
   WidgetsBinding.instance.addPostFrameCallback((_){
     setState(() {
       print("click....");
       _initialChildSize = 1;
       _maxChildSize = 1;
     });
   });
  }


  @override
  void initState() {
    _debouncedCallDataForStartingLocation = DebounceClass.debounce(_callDataForStartingLocation, const Duration(milliseconds: 300));
    _debouncedCallDataForDestination = DebounceClass.debounce(_callDataForDestination, const Duration(milliseconds: 300));
   // _draggableScrollableController.addListener(_handleScrolling);
    _draggableScrollableController.addListener(() {
      // print("scroll......${_draggableScrollableController.size}");
      // if (_draggableScrollableController.size > 0.3) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     setState(() {
      //       _initialChildSize = 1.0;
      //     });
      //   });
      //
      // } else if(_draggableScrollableController.size  == 0.3){
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     setState(() {
      //       _initialChildSize = 0.3;
      //     });
      //   });
      //
      // }
     /// FocusScope.of(context).unfocus();
    });
    //
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
    super.initState();
  }

  Future<void> initialize() async {
    await clearData();
    await _deleteDatabase();
    await setCustomMarkerIcon();
   // _showBottomModalWithoutDateButton();
    await fetchingOnlyCurrentAddress();
   // await initializeService();
  }

  Future<void> clearData() async {
    polyLinesMap = {};
    waypoints = [];
    destination = LatLng(0, 0);
    originLocation = LatLng(0, 0);
    isNeedToRedraw = false;
    originalRoutePoints = [];
    _initialChildSize = 0.3;
    _maxChildSize = 1.0;
    isDestinationField = false;
    startLocationController.clear();
    destinationController.clear();
    isConfirmOrigin = false;
    isConfirmDestination = false;
    setState(() {});
  }
  var snackdemo = SnackBar(
    content: Text('Procced'),
    backgroundColor: Colors.green,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(5),
  );




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorManager.homeBg,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, ShowTrackedScreen.route);
            },
            child: Text("show route"),
          ),
          TextButton(
            onPressed: () async{
              setState(() {
                movingMood = "walk";
                isNeedToRedraw = true;
              });
              //updateCurrentLocation();
              //await _deleteDatabase();
             // updateCurrentLocationWithLocationPackage();
            },
            child: Text("walking"),
          ),
          TextButton(
            onPressed: () async{
              setState(() {
                movingMood = "drive";
                isNeedToRedraw = true;
              });
              //updateCurrentLocation();
            //  await _deleteDatabase();
              //updateCurrentLocationWithLocationPackage();
            },
            child: Text("driving"),
          ),
          TextButton(
            onPressed: () async {
              await cancelTracking();
              await clearData();
              fetchCurrentLocationWithLocationPackage();
            },
            child: Text("end"),
          ),
    
          // if(isTwoPointSame) TextButton(
          //   onPressed: () async {
          //   },
          //   child: Text("two same"),
          // ),
    
        ],
      ),
      body: currentPosition == null
          ? SafeArea(child: Center(child: CircularProgressIndicator()))
          : SafeArea(
            child: Stack(
                    children: [
            GoogleMap(
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: currentPosition!,
                zoom: 13,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  icon: currentIcon,
                  position: currentPosition!,
                ),
                /*if(!isTwoPointSame)*/Marker(
                  markerId: MarkerId("sourceLocation"),
                  icon: originIcon,
                  position: originLocation,
                ),
                Marker(
                  markerId: MarkerId("destinationLocation"),
                  icon: destinationIcon,
                  position: destination,
                ),
              },
              polylines: Set<Polyline>.of(polyLinesMap.values),
              onTap: (LatLng tappedPoint) {
                setState(() {
                  waypoints.add(PointLatLng(tappedPoint.latitude, tappedPoint.longitude));
                  _addMarker(tappedPoint);
                });
              },
              onMapCreated: (mapController) {
                completerController.complete(mapController);
              },
            ),
            DraggableScrollableSheet(
              controller: _draggableScrollableController,
              initialChildSize: _initialChildSize,
              minChildSize: 0.3,
              maxChildSize: _maxChildSize,
              builder: (BuildContext context, ScrollController scrollController) {
               // print("build....${scrollController.initialScrollOffset}");
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      _buildSearchForStartingLocation(scrollController),
                      _buildSearchForDestination(scrollController),
                      SizedBox(height: 10,),
                      if(_maxChildSize == 1 && _initialChildSize == 1) Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Container(
                          color: Colors.black12,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: (){
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _initialChildSize = 0.3;
                                });
                              },
                              child: Row(
                                children: [
                                  Text("Set On Map"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if(_maxChildSize == 1 && _initialChildSize == 1)SizedBox(height: 10,),
                      if(_maxChildSize == 1 && _initialChildSize == 1)Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: originSearchResults.length,
                          itemBuilder: (context, index) {
                            final result = originSearchResults[index]["description"];
                            return ListTile(
                              title: Text(result.toString(), style: TextStyle(fontSize: 14),),
                              onTap: () async{
                                if(isDestinationField){
                                  setState(() {
                                    destinationPlaceId = originSearchResults[index]["place_id"];
                                  });
                                  dynamic placeDetails = await fetchPlaceDetails(destinationPlaceId);
                                  destination = LatLng(placeDetails["geometry"]["location"]["lat"], placeDetails["geometry"]["location"]["lng"]);
                                  destinationController.text = result.toString();
                                  _initialChildSize = 0.3;
                                  _maxChildSize = 0.3;
                                  FocusScope.of(context).unfocus();
                                  final coordinateList = await computeRoutes();
                                  generatePolyLineFromPoint(coordinateList);
                                  completerController.future.then((controller) {
                                    controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                                          zoom: 14.0,
                                        ),
                                      ),
                                    );
                                  });
                                  setState(() {
                                  });
                                }else{
                                  startLocationController.text = result.toString();
                                  setState(() {
                                    originPlaceId = originSearchResults[index]["place_id"];
                                  });
                                  dynamic placeDetails = await fetchPlaceDetails(originPlaceId);
                                  originLocation = LatLng(placeDetails["geometry"]["location"]["lat"], placeDetails["geometry"]["location"]["lng"]);
                                  setState(() {
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                      if(destinationController.text.isNotEmpty)Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10, top: 10),
                        child: CustomElevatedButton(
                          buttonWidth: double.infinity,
                          onPressed: ()async{
                            //  await setRoute();
                            // final coordinateList = await fetchPolylinePointsWithGoogleApi();
                            await cancelTracking();
                            await _deleteDatabase();
                            setState(() {
                              isNeedToRedraw = false;
                            });
                            final coordinateList = await computeRoutes();
                            await generatePolyLineFromPoint(coordinateList);
                            //await updateCurrentLocation();
                            completerController.future.then((controller) {
                              controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                                    zoom: 14.0,
                                  ),
                                ),
                              );
                            });
                            await updateCurrentLocationWithLocationPackage();
                            },
                          text: "Start",
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
                    ],
                  ),
          ),
    );
  }

  Future<void> setCustomMarkerIcon() async {
    BitmapDescriptor.asset(
        ImageConfiguration(size: Size(40, 40)), "assets/icons/origin.png")
        .then((icon) {
      originIcon = icon;
    });
    BitmapDescriptor.asset(
        ImageConfiguration(size: Size(40, 40)), "assets/icons/destination.png")
        .then((icon) {
      destinationIcon = icon;
    });
    BitmapDescriptor.asset(
        ImageConfiguration(size: Size(50, 50)), "assets/icons/current.png")
        .then((icon) {
      currentIcon = icon;
    });
    setState(() {});
  }

  Future<void> fetchingOnlyCurrentAddress()async{
    //Position position = await fetchCurrentLocationWithGeoCoding();
    loc.LocationData position = await fetchCurrentLocationWithLocationPackage();
    CallClass.isNowCall = true;
    currentAddress = await getAddressFromLatLng(position);
    setState(() {
      //startLocationController.text = currentAddress;
    });
  }




  // fetch location for updating
  Future<loc.LocationData> fetchCurrentLocationWithLocationPackage()async{
    try{
      bool serviceEnable;
      loc.PermissionStatus permissionStatus;
      //to check service enable status
      serviceEnable = await locationController.serviceEnabled();
      if(serviceEnable){
        serviceEnable = await locationController.requestService();
      }else{
        return Future.error('Location permissions are denied');
      }

      //check the permission status
      permissionStatus = await locationController.hasPermission();
      if(permissionStatus == loc.PermissionStatus.denied){
        permissionStatus = await locationController.requestPermission();
        if(permissionStatus != loc.PermissionStatus.granted){
          return Future.error('Location permissions are denied');
        }
      }

      final locationData = await locationController.getLocation();
      currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
      originLocation = LatLng(locationData.latitude!, locationData.longitude!);
      currentAddress = await getAddressFromLatLng(locationData);
      startLocationController.text = currentAddress;
      setState(() {

      });
      return locationData;


    }catch(err){
      print("err...$err");
    }
    return Future.error('Location permissions are denied');
  }


  Future<void> updateCurrentLocationWithLocationPackage()async{
    try{
      await fetchCurrentLocationWithLocationPackage();
      //first time get location
      locationSubscription = await locationController.onLocationChanged.listen((location)async{
        currentPosition = LatLng(location.latitude!, location.longitude!);
        setState(() {});
        await storeDataInSqflite(latitude: location.latitude!, longitude: location.longitude!);
       //  Timer(const Duration(seconds: 10), (){
       //    storeDataInSqflite(latitude: location.latitude!, longitude: location.longitude!);
       //  });

        // bool isSame = areLocationsClose(
        //   currentLocation: currentPosition!,
        //   originOrDestinationLocation: originLocation,
        //   thresholdInMeters: 30,
        // );

        //print("isSame....$isSame");

        // if (isSame){
        //   isTwoPointSame = true;
        //   isNeedToRedraw = true;
        //   originLocation = LatLng(location.latitude!, location.longitude!);
        //   //currentAddress = await getAddressFromLatLng(position);
        //   //final coordinateList = await fetchPolylinePointsWithGoogleApi();
        //   final coordinateList = await computeRoutes();
        //   generatePolyLineFromPoint(coordinateList);
        //   setState(() {});
        // } else {
        //   isTwoPointSame = false;
        //   if(isNeedToRedraw){
        //     originLocation = LatLng(location.latitude!, location.longitude!);
        //     final coordinateList = await computeRoutes();
        //     generatePolyLineFromPoint(coordinateList);
        //   }
        //   setState(() {});
        // }

        // Check if the user has deviated from the original route
        if (await hasDeviatedFromRoute(currentPosition!, originalRoutePoints, threshold: 20)) {
          print("hasDeviatedFromRoute.....1");
          isNeedToRedraw = true;
          final newRoutePoints = await computeRoutes();
          generatePolyLineFromPoint(newRoutePoints);
          isNeedToRedraw = false;
        }

        //LatLng(23.7221459, 90.4305929)
        // // LatLng(23.722445377416133, 90.43041910976171)
        // print("currenPostion....$currentPosition");
        // //currentPosition =LatLng(23.726731821683835, 90.42114805430174);
        // // Reverse geocode to get address
        // currentAddress = await getAddressFromLatLng(currentPosition!);
        // startLocationController.text = currentAddress;
        // setState(() {
        //
        // });
      });
      locationController.enableBackgroundMode(enable: true);
    }catch(err){
    }
  }




  Future<List<LatLng>> computeRoutes(/*{required LatLng start, required LatLng end}*/) async {
    final url = 'https://routes.googleapis.com/directions/v2:computeRoutes';
    // final headers = {
    //   'Content-Type': 'application/json',
    //   'Authorization': 'Bearer $googleApiKey',
    // };

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': googleApiKey,
      //'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
      'X-Goog-FieldMask': '*',
    };

    final body = jsonEncode({
      'origin': {
        'location': {
          'latLng': {
            'latitude': originLocation.latitude,
            'longitude': originLocation.longitude,
          }
        }
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          }
        }
      },
      'travelMode': movingMood.toUpperCase(),
      //'routingPreference': 'TRAFFIC_AWARE_OPTIMAL',
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      logger.i("computeRoutes....${response.body}");

      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   Logger().i("Routes data: $data");
      // } else {
      //   Logger().e("Failed to load routes: ${response.body}");
      // }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List;

        if (routes.isNotEmpty) {
          final points = routes[0]['polyline']['encodedPolyline'] as String;
          final coordinates = PolylinePoints().decodePolyline(points);
          // ///TODO REMOVE
          //  await _deleteDatabase();
          // coordinates.map((points)async{
          //    await storeDataInSqflite(latitude: points.latitude, longitude: points.longitude);
          // }).toList();
          originalRoutePoints = coordinates.map((point) => LatLng(point.latitude, point.longitude)).toList();
          return originalRoutePoints;
        }
      } else {
        logger.e("Failed to load routes: ${response.body}");
      }
    } catch (e) {
      Logger().e("Error making request: $e");
    }
    return [];
  }



  Future<void> generatePolyLineFromPoint(List<LatLng> points) async{
    final PolylineId polylineId = PolylineId("route");
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      color: Colors.blue,
      points: points,
      width: 5,
    );

    polyLinesMap[polylineId] = polyline;
    setState(() {});
  }

  // Future<String> getAddressFromLatLng(Position position) async {
  //   try {
  //     List<geoLoc.Placemark> placemarks =
  //     await geoLoc.placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );
  //     logger.i("getAddressFromLatLng....${placemarks}");
  //
  //     if (placemarks.isNotEmpty) {
  //       final place = placemarks[0];
  //       return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
  //     }
  //   } catch (e) {
  //     Logger().e("Error fetching address: $e");
  //   }
  //   return "Unknown location";
  // }

    Future<String>  getAddressFromLatLng3(/*Position*/ loc.LocationData position) async {

    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url = '$_host?key=$googleApiKey&language=en&latlng=${position.latitude},${position.longitude}';

      // String _host = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
      // final url = '$_host?location=${position.latitude},${position.longitude}&radius=50&key=$googleApiKey';


    print("address+url.....$url");
    if(position.latitude != null && position.longitude != null){
      var response = await http.get(Uri.parse(url));
      logger.i("getAddressFromLatLng..${response.body}");
      //firstTimeCurretnLocaton....LatLng(23.722151, 90.4306274)
      //getAddressFromLatLng....LatLng(23.7220806,  90.43066689999999)
      //getLatLngFromAddress....LatLng(23.804093,  90.4152376)
      if(response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        String _formattedAddress = data["results"][0]["formatted_address"];

       // originPlaceId = data["results"][0]["place_id"].toString();


      //  await getLatLngFromAddress(_formattedAddress);
        print("response ==== $_formattedAddress");
        return _formattedAddress;
      } else return "";
    } else return "";
  }


  Future<String> getAddressFromLatLng(/*Position*/ loc.LocationData position) async {
    // String _host = 'https://maps.google.com/maps/api/geocode/json';
    // final url = '$_host?key=$googleApiKey&language=en&latlng=${position.latitude},${position.longitude}';
    String _host = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    final url = '$_host?location=${position.latitude},${position.longitude}&radius=50&key=$googleApiKey';
    print("address+url.....$url");
    if(position.latitude != null && position.longitude != null){
      var response = await http.get(Uri.parse(url));
      logger.i("getAddressFromLatLng..${response.body}");
      //firstTimeCurretnLocaton....LatLng(23.722151, 90.4306274)
      //getAddressFromLatLng....LatLng(23.7220806,  90.43066689999999)
      //getLatLngFromAddress....LatLng(23.804093,  90.4152376)
      if(response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        String _formattedAddress = data["results"][0]["name"];
       // currentLatLongPosition = data["results"][0]["geometry"]["location"];
       // originPlaceId = data["results"][0]["place_id"].toString();
        double minDistance = 1000000000;

        for(var locationData in data["results"]){
          LatLng secondLocation = LatLng(
            locationData["geometry"]["location"]["lat"],
            locationData["geometry"]["location"]["lng"],
          );
          double distance = getDistance(firstLocation: LatLng(position.latitude!, position.longitude!), secondLocation: secondLocation);
         // print("distance....$distance....minDistance...$minDistance");
          if(distance < minDistance){
            minDistance = distance;
            _formattedAddress = locationData["name"];
          }
        }





        //  await getLatLngFromAddress(_formattedAddress);
        print("response ==== $_formattedAddress");
        return _formattedAddress;
      } else return "";
    } else return "";
  }





  // Future<String> getAddressFromLatLng(/*Position*/ loc.LocationData position) async {
  //   String _host = 'https://maps.google.com/maps/api/geocode/json';
  //   final url = '$_host?key=$googleApiKey&language=en&latlng=${position.latitude},${position.longitude}';
  //   print("address+url.....$url");
  //   if (position.latitude != null && position.longitude != null) {
  //     var response = await http.get(Uri.parse(url));
  //     logger.i("getAddressFromLatLng..${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       Map data = jsonDecode(response.body);
  //       if (data["results"].isNotEmpty) {
  //         // Parse the first result
  //         var result = data["results"][0];
  //         String formattedAddress = result["formatted_address"];
  //         currentLatLongPosition = result["geometry"]["location"];
  //         originPlaceId = result["place_id"].toString();
  //
  //         print("currentLatLongPostion.....${currentLatLongPosition}");
  //         await getLatLngFromAddress(formattedAddress);
  //
  //         // Check if the address is in plus code format and refine it
  //         if (formattedAddress.contains("plus_code")) {
  //           // Construct a more readable address from address components
  //           List addressComponents = result["address_components"];
  //           String readableAddress = "";
  //           for (var component in addressComponents) {
  //             if (component["types"].contains("street_number") ||
  //                 component["types"].contains("route") ||
  //                 component["types"].contains("locality")  ||
  //                 component["types"].contains("administrative_area_level_1") ||
  //                 component["types"].contains("country")) {
  //               readableAddress += component["long_name"] + ", ";
  //             }
  //           }
  //           formattedAddress = readableAddress.trim().trimRight(',');
  //         }
  //
  //         print("response ==== $formattedAddress");
  //         return formattedAddress;
  //       } else {
  //         return "No results found";
  //       }
  //     } else {
  //       return "Error: ${response.statusCode}";
  //     }
  //   } else {
  //     return "Invalid position";
  //   }
  // }




  Future<LatLng?> getLatLngFromAddress(String address) async {
    final formattedAddress = Uri.encodeQueryComponent(address);
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?address=$formattedAddress&key=$googleApiKey");
    final response = await http.get(url);
    print("latlong+url.....$url");
    logger.i("getLatLngFromAddress.....${response.body}");

    //firstTimeCurretnLocaton....LatLng(23.722151, 90.4306274)
    //getAddressFromLatLng....LatLng(23.7220806,  90.43066689999999)
    //getLatLngFromAddress....LatLng(23.804093,  90.4152376)

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["results"].isNotEmpty) {
        final location = data["results"][0]["geometry"]["location"];
        final latitude = location["lat"];
        final longitude = location["lng"];
        return LatLng(latitude, longitude);
      } else {
        print("No location found for this address.");
        return null;
      }
    } else {
      // Handle errors (e.g., invalid API key, network issues)
      print("Error fetching location: ${response.statusCode}");
      return null;
    }
  }

  bool areLocationsClose({
    required LatLng currentLocation,
    required LatLng originOrDestinationLocation,
    required double thresholdInMeters,
  }) {
    double distance = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      originOrDestinationLocation.latitude,
      originOrDestinationLocation.longitude,
    );
    //print("distance....$distance");
    return distance < thresholdInMeters;
  }

  double getDistance({
    required LatLng firstLocation,
    required LatLng secondLocation,
  }) {
    double distance = Geolocator.distanceBetween(
      firstLocation.latitude,
      firstLocation.longitude,
      secondLocation.latitude,
      secondLocation.longitude,
    );
    return distance ;
  }

  Future<void> cancelTracking() async {
    // positionStreamSubscription?.cancel();
    // setState(() {
    //   isUpdateCurrentLocation = false;
    // });
    locationSubscription?.cancel();  // Cancel the subscription
    locationController.enableBackgroundMode(enable: false);
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }




  Future<dynamic> searchLocations(String query) async {
    String country = "BD";
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey&components=country:$country';
   // final url = 'https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=$query&key=$googleApiKey';
    print("searchUrl....$url");

    try {
      final response = await http.get(Uri.parse(url));
      logger.i("serachResult....${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;
        originSearchResults = predictions;
        setState(() {

        });
        return predictions;
        // searchResults = predictions;
        //print("searchResults...${searchResults[0]}");

        setState(() {
          //searchResults = predictions.map((p) {}).toList();
          //print("searchResults...${searchResults[0]}");
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      Logger().e("Error fetching predictions: $e");
    }
  }


  Future<dynamic> fetchPlaceDetails(String placeId) async {
    final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey';
    print("placedetails_url....$url");
    try {
      final response = await http.get(Uri.parse(url));
      logger.i("places details.....${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        } else {
          throw Exception('Failed to fetch place details: ${data['status']}');
        }
      } else {
        throw Exception('Failed to fetch place details');
      }
    } catch (e) {
      print("Error fetching place details: $e");
      rethrow;
    }
  }

  Future<bool> hasDeviatedFromRoute(LatLng currentPosition, List<LatLng> routePoints, {double threshold = 30.0}) async{
    double minDistance = 10000000000013;
    double distance = 0;
    print("threshold..$threshold");
    for (LatLng point in routePoints) {
      distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        point.latitude,
        point.longitude,
      );
      print("distance....$distance");
      minDistance = min(distance, minDistance);
    }
    print("deviated_distance....$distance");
    print("mindistance....$minDistance");
    if (minDistance < threshold) {
      return false;
    }
    return true;
  }


  Future<void> _deleteDatabase()async{
    await SqfLitDb.deleteDatabaseFile(databaseName: databaseName);
  }

  Future<void> deleteTable()async{
    await SqfLitDb.deleteAnyTableDataFromLocalDb(tableName: tableName);
  }

  storeDataInSqflite({double latitude = 0, double longitude = 0})async{
    var map = {
      "latitude": "$latitude",
      "longitude": "$longitude",
    };
    String tableInfo =  "CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, latitude TEXT, longitude TEXT)";
    await SqfLitDb.createDatabaseAndInsertDataInTable(tableName: tableName, createTableInformation: tableInfo, map: map, databaseName: databaseName);
  }

  void _addMarker(LatLng tappedPoint)async {
    final markerId = MarkerId(tappedPoint.toString());
    final marker = Marker(
      markerId: markerId,
      position: tappedPoint,
      infoWindow: InfoWindow(title: "Selected Location"),
    );

    loc.LocationData value = convertLatLngToLocationData(tappedPoint);
    print("tappedTest....${value}");
    print("tappedTest....${value.latitude}");

    markers[markerId] = marker;
    if(isDestinationField) {
      destination = tappedPoint;
      loc.LocationData value = convertLatLngToLocationData(destination);
      destinationController.text = await getAddressFromLatLng(value);
    }
    else {
      originLocation = tappedPoint;
      loc.LocationData value = convertLatLngToLocationData(originLocation);
      startLocationController.text = await getAddressFromLatLng(value);
    }

    setState(() {
    });
  }

  loc.LocationData convertLatLngToLocationData(LatLng latLng) {
    return loc.LocationData.fromMap({
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    });
  }

}

