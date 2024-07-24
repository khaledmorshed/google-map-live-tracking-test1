// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geocoding/geocoding.dart' as geoLoc;
// import 'package:geolocator/geolocator.dart';
// import 'package:google_map_live_tracking/utils/app_config.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as loc;
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';
//
// import '../data/repositories/local/sqflite/sqf_lite_db.dart';
//
//
//
// class HomeScreen extends StatefulWidget {
//   static const String route = "/HomeScreen";
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   //farmegate
//   //static LatLng destinationWithLocationPackage = LatLng(23.7568, 90.3901);
//   static Position? destinationWithGeoLocatorPackage;
//   //manik nagar
//   //23.722312469301194, 90.42867869138718
//   //static LatLng destination = LatLng(23.722312469301194, 90.42867869138718);
//   //ittefagmor
//   //static LatLng originLocationWithLocationPackage = LatLng(23.7220, 90.4214);
//   static Position? originLocationWithGeoLocatorPackage;
//   //shapla chattar
//   //23.72613053091123, 90.42172338813543
//  // static LatLng originLocation = LatLng(23.72613053091123, 90.42172338813543);
//   //static LatLng googlePlex = LatLng(-90.0, -122.084);
//   static LatLng mountainView = LatLng(-90.0, -122.084);
//   //static LatLng destination = LatLng(37.7749, -122.4194);
//
//   final Completer<GoogleMapController> completerController = Completer();
//   final locationController = loc.Location();
//   //motijheel
//   //23.726731821683835, 90.42114805430174
//   LatLng? currentPositionLocationPackage;
//   Position? currentPositionGeoLocatorPackage;
//   Map<PolylineId, Polyline> polyLinesMap = {};
//   List<PointLatLng> waypoints = [];
//   final changeLatTextEditingController = TextEditingController();
//   final changeLongTextEditingController = TextEditingController();
//   String movingMood = "driving";
//   BitmapDescriptor originIcon = BitmapDescriptor.defaultMarker;
//   BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
//   BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;
//   bool isUpdateCurrentLocation = false;
//   bool isTwoPointSame = false;
//
//   final startLocationController = TextEditingController();
//   final destinationController = TextEditingController();
//
//   StreamSubscription<loc.LocationData>? locationSubscription;
//   String currentAddress = "";
//   var logger = Logger();
//
//
//   initialize()async{
//     // startLocationController.text = "mohakhali, dhaka";
//     // destinationController.text = "farmgate, dhaka";
//     ///await _deleteDatabase();
//     await clearData();
//     await setCustomMarkerIcon();
//     //await fetchCurrentLocation();
//     await getCurrentAddress();
//     //fetching polyline points between source to destination
//     //final coordinateList = await fetchPolylinePointsWithDirectionApi();
//     // final coordinateList = await fetchPolylinePointsWithRouteApi();
//     // //make path with the coordinate point between source to destination
//     // generatePolyLineFromPoint(coordinateList);
//   }
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_){
//       initialize();
//     });
//     super.initState();
//   }
//
//   clearData()async{
//     polyLinesMap = {};
//     waypoints = [];
//     //destinationWithLocationPackage = LatLng(0, 0);
//    // originLocationWithLocationPackage = LatLng(0, 0);
//     originLocationWithGeoLocatorPackage = null;
//     destinationWithGeoLocatorPackage = null;
//     setState(() {
//
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//    // print("ccurrentPosition....build...$currentPosition");
//     return  SafeArea(
//       child: Scaffold(
//         appBar:  AppBar(
//          // title:  const Text("tracking", maxLines: 1, style: TextStyle(color: Colors.red),),
//           backgroundColor: Colors.blue,
//           actions: [
//             TextButton(onPressed: (){
//               setState(() {
//                 movingMood = "walking";
//               });
//               updateCurrentLocation();
//             }, child: Text("walking")),
//             TextButton(onPressed: (){
//               setState(() {
//                 movingMood = "driving";
//               });
//               updateCurrentLocation();
//             }, child: Text("driving")),
//             TextButton(onPressed: ()async{
//               //updateCurrentLocation();
//               //await fetchCurrentLocation();
//             }, child: Text("my_loca")),
//             // if(isTwoPointSame)TextButton(onPressed: (){
//             //
//             // }, child: Text("two")),
//
//           ],
//         ),
//         body: currentPositionLocationPackage == null ? Center(child: CircularProgressIndicator(),) : Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: startLocationController,
//                     decoration: InputDecoration(hintText: "Start Location"),
//                   ),
//                   SizedBox(height: 8),
//                   TextField(
//                     controller: destinationController,
//                     decoration: InputDecoration(hintText: "Destination"),
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: ()async{
//                         //  await fetchCurrentLocation();
//                          // await updateCurrentLocation();
//                           await setRoute();
//                           await updateCurrentLocation();
//                         },
//                         child: Text("start"),
//                       ),
//                       SizedBox(width: 30,),
//                       ElevatedButton(
//                         onPressed: ()async{
//                           await cancelTracking();
//                           await clearData();
//                          // fetchCurrentLocation();
//                         },
//                         child: Text("end"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: GoogleMap(
//                 myLocationEnabled: true,
//                 trafficEnabled: true,
//                 initialCameraPosition: CameraPosition(
//                     target: LatLng(currentPositionLocationPackage!.latitude, currentPositionLocationPackage!.longitude),
//                     zoom: 13,
//                   ),
//                 markers: {
//                   Marker(
//                       markerId: const MarkerId("currentLocation"),
//                       icon: currentIcon,
//                       position: LatLng(currentPositionLocationPackage!.latitude, currentPositionLocationPackage!.longitude),
//                   ),
//                   //  /*if(!isUpdateCurrentLocation)*/Marker(
//                   //     markerId: MarkerId("sourceLocation"),
//                   //     icon: originIcon,
//                   //     position: LatLng(originLocationWithGeoLocatorPackage!.longitude, originLocationWithGeoLocatorPackage!.longitude)
//                   // ),
//                   //  Marker(
//                   //     markerId: MarkerId("destinationLocation"),
//                   //     icon: destinationIcon,
//                   //     position: LatLng(destinationWithGeoLocatorPackage!.longitude, destinationWithGeoLocatorPackage!.longitude)
//                   // ),
//                 },
//                 polylines: Set<Polyline>.of(polyLinesMap.values),
//                //  polylines: {
//                //
//                //  },
//                 onTap: (LatLng tappedPoint) {
//                   print("TAPPOINT#...${tappedPoint}");
//                   setState(() {
//                     waypoints.add(PointLatLng(tappedPoint.latitude, tappedPoint.longitude));
//                   });
//                 },
//                 onLongPress: (LatLng tappedPoint) {
//                   print("LONPRESS#...${tappedPoint}");
//                   setState(() {
//                     waypoints.add(PointLatLng(tappedPoint.latitude, tappedPoint.longitude));
//                   });
//                 },
//                 onMapCreated: (mapController){
//                   completerController.complete(mapController);
//                 },
//               ),
//             ),
//
//             // TextFormField(
//             //   controller: changeLatTextEditingController,
//             //   decoration: InputDecoration(
//             //       hintText: "lat"
//             //   ),
//             // ),
//             // SizedBox(height: 10,),
//             // TextFormField(
//             //   controller: changeLongTextEditingController,
//             //   decoration: InputDecoration(
//             //       hintText: "long"
//             //   ),
//             // ),
//
//             // ElevatedButton(onPressed: ()async{
//             //
//             // }, child: Text("change route")),
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   //marker
//   Future<void> setCustomMarkerIcon()async{
//     BitmapDescriptor.asset(ImageConfiguration(size: Size(40, 40)), "assets/icons/origin.png").then((icon){
//       originIcon = icon;
//     });
//     BitmapDescriptor.asset(ImageConfiguration(size: Size(40, 40)), "assets/icons/destination.png").then((icon){
//       destinationIcon = icon;
//     });
//     BitmapDescriptor.asset( ImageConfiguration(size: Size(50, 50)), "assets/icons/current.png").then((icon){
//       currentIcon = icon;
//     });
//     setState(() {
//
//     });
//   }
//
//
//   //fetch location for updating
//   // Future<void> fetchCurrentLocationWithLocationPackage()async{
//   //   try{
//   //     bool serviceEnable;
//   //     loc.PermissionStatus permissionStatus;
//   //
//   //     //to check service enable status
//   //     serviceEnable = await locationController.serviceEnabled();
//   //     if(serviceEnable){
//   //       serviceEnable = await locationController.requestService();
//   //     }else{
//   //       return;
//   //     }
//   //
//   //     //check the permission status
//   //     permissionStatus = await locationController.hasPermission();
//   //     if(permissionStatus == loc.PermissionStatus.denied){
//   //       permissionStatus = await locationController.requestPermission();
//   //       if(permissionStatus != loc.PermissionStatus.granted){
//   //         return;
//   //       }
//   //     }
//   //
//   //     //first time get location
//   //     await locationController.getLocation().then((location)async{
//   //       currentPosition = LatLng(location.latitude!, location.longitude!);
//   //       //LatLng(23.7221459, 90.4305929)
//   //      // LatLng(23.722445377416133, 90.43041910976171)
//   //       print("currenPostion....$currentPosition");
//   //       //currentPosition =LatLng(23.726731821683835, 90.42114805430174);
//   //       // Reverse geocode to get address
//   //       currentAddress = await getAddressFromLatLng(currentPosition!);
//   //       startLocationController.text = currentAddress;
//   //       setState(() {
//   //
//   //       });
//   //     });
//   //   }catch(err){
//   //     print("err...$err");
//   //   }
//   // }
//
//
//
//   Future<Position> fetchCurrentLocationWithGeoLocator() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Test if location services are enabled.
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled don't continue
//       // accessing the position and request users of the
//       // App to enable the location services.
//       return Future.error('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions are denied, next time you could try
//         // requesting permissions again (this is also where
//         // Android's shouldShowRequestPermissionRationale
//         // returned true. According to Android guidelines
//         // your App should show an explanatory UI now.
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are denied forever, handle appropriately.
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//
//     // When we reach here, permissions are granted and we can
//     // continue accessing the position of the device.
//     currentPositionGeoLocatorPackage =  await Geolocator.getCurrentPosition();
//     return currentPositionGeoLocatorPackage!;
//   }
//
//   Future<void> getCurrentAddress()async{
//     Position position = await fetchCurrentLocationWithGeoLocator();
//     currentAddress = await getAddressFromLatLngWithGeoLocatorPackage(position);
//     startLocationController.text = currentAddress;
//     setState(() {
//
//     });
//   }
//
//
//   //fetch location for updating
//   Future<void> updateCurrentLocation()async{
//     try{
//       final LocationSettings locationSettings = LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 100,
//       );
//       StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
//               (Position? position) {
//                 currentPositionGeoLocatorPackage = position;
//                 setState(() {
//
//                 });
//             print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
//           });
//     }catch(err){
//       print("err...$err");
//     }
//   }
//
//
//   Future<List<LatLng>> fetchPolylinePointsWithRouteApi() async {
//     final url = Uri.parse(
//         "https://maps.googleapis.com/maps/api/directions/json?"
//             "origin=${originLocationWithGeoLocatorPackage!.latitude},${originLocationWithGeoLocatorPackage!.longitude}"
//             "&destination=${destinationWithGeoLocatorPackage!.latitude},${destinationWithGeoLocatorPackage!.longitude}"
//             "&mode=$movingMood"
//             "&waypoints=${waypoints.map((wp) => "${wp.latitude},${wp.longitude}").join(',')}" // Add waypoints if needed
//             "&key=${googleApiKey}");
//     try{
//       final response = await http.get(url);
//       print("response.....3+${response}");
//
//
//       logger.d("Logger is working!");
//      // logger.i(response.body);
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         final routes = jsonResponse['routes'] as List;
//
//         if (routes.isNotEmpty) {
//           final points = routes[0]['overview_polyline']['points'] as String;
//           final coordinates = PolylinePoints().decodePolyline(points);
//           return coordinates.map((point) => LatLng(point.latitude, point.longitude)).toList();
//         }
//       } else {
//         print("Error fetching route: ${response.statusCode}"); // Handle error
//       }
//     }catch(err){
//       print("catch Error : $err");
//       return [];
//     }
//     return [];
//   }
//
//
//
//   //generate polyline from points to generate the path
//   Future<void> generatePolyLineFromPoint(List<LatLng> polylineCoordinates)async{
//     //print("polylineCoordinates...${polylineCoordinates}");
//   //   const id = PolylineId("polyline");
//   //   final polyline = Polyline(
//   //     polylineId: id,
//   //     color: Colors.blueAccent,
//   //     points: polylineCoordinates,
//   //     width: 5,
//   //   );
//   //   setState(() {
//   //     polyLinesMap[id] = polyline;
//   //   });
//
//     const id = PolylineId("polyline");
//     final polyline = Polyline(
//       polylineId: id,
//       color: Colors.blueAccent,
//       points: polylineCoordinates,
//       width: 5,
//     );
//     setState(() {
//       polyLinesMap[id] = polyline;
//     });
//
//     // Separate completed and remaining path
//     List<LatLng> completedPolylineCoordinates = [];
//     List<LatLng> remainingPolylineCoordinates = [];
//     bool completedSegment = true;
//
//     for (LatLng point in polylineCoordinates) {
//       if (completedSegment && Geolocator.distanceBetween(
//         currentPositionLocationPackage!.latitude,
//         currentPositionLocationPackage!.longitude,
//         point.latitude,
//         point.longitude,
//       ) < 20) {
//         completedPolylineCoordinates.add(point);
//       } else {
//         completedSegment = false;
//         remainingPolylineCoordinates.add(point);
//       }
//     }
//
//     const completedId = PolylineId("completed_polyline");
//     final completedPolyline = Polyline(
//       polylineId: completedId,
//       color: Colors.green,
//       points: completedPolylineCoordinates,
//       width: 5,
//     );
//
//     const remainingId = PolylineId("remaining_polyline");
//     final remainingPolyline = Polyline(
//       polylineId: remainingId,
//       color: Colors.blueAccent,
//       points: remainingPolylineCoordinates,
//       width: 5,
//     );
//
//     setState(() {
//       polyLinesMap[completedId] = completedPolyline;
//       polyLinesMap[remainingId] = remainingPolyline;
//     });
//
//     // Debug print to check polyline coordinates
//    // print("Completed Polyline Coordinates: $completedPolylineCoordinates");
//     //print("Remaining Polyline Coordinates: $remainingPolylineCoordinates");
//
//   }
//
//
//   Future<void> setRoute() async {
//     try{
//       if (startLocationController.text.isNotEmpty &&
//           destinationController.text.isNotEmpty) {
//         List<geoLoc.Location> startPlacemark = await geoLoc.locationFromAddress(startLocationController.text);
//         logger.i("startPlacemark..${startPlacemark}");
//         List<geoLoc.Location> destinationPlacemark = await geoLoc.locationFromAddress(destinationController.text);
//         logger.i("destinationPlacemark..${destinationPlacemark}");
//
//         if (startPlacemark.isNotEmpty && destinationPlacemark.isNotEmpty) {
//           originLocationWithLocationPackage = LatLng(startPlacemark[0].latitude, startPlacemark[0].longitude);
//           destinationWithLocationPackage = LatLng(destinationPlacemark[0].latitude, destinationPlacemark[0].longitude);
//
//           setState(() {
//             isUpdateCurrentLocation = false;
//           });
//           // Fetching polyline points between source to destination
//           final coordinateList = await fetchPolylinePointsWithRouteApi();
//           // Make path with the coordinate points between source to destination
//           generatePolyLineFromPoint(coordinateList);
//         }
//       }
//     }catch(err){
//       print("find error....$err");
//     }
//   }
//
//   // Cancel tracking
//   Future<void> cancelTracking() async{
//     locationSubscription?.cancel();  // Cancel the subscription
//     locationController.enableBackgroundMode(enable: false);  // Disable background mode
//   }
//
//
//   bool areLocationsClose({required LatLng currentLocation, required LatLng originOrDestinationLocation, double thresholdInMeters = 1.0}) {
//     double distanceInMeters = Geolocator.distanceBetween(
//       currentLocation.latitude,
//       currentLocation.longitude,
//       originOrDestinationLocation.latitude,
//       originOrDestinationLocation.longitude,
//     );
//     return distanceInMeters <= thresholdInMeters;
//   }
//
//   Future<String> getAddressFromLatLng3(LatLng position) async {
//     try {
//       List<geoLoc.Placemark> placemarks = await geoLoc.placemarkFromCoordinates(position.latitude, position.longitude);
//       logger.i("placemarks: $placemarks");
//       if (placemarks.isNotEmpty) {
//         final placemark = placemarks.first;
//         return "${placemark.street}, ${placemark.name}, ${placemark.locality}, ${placemark.country}";
//       }
//     } catch (e) {
//       print("Error getting address: $e");
//     }
//     return "Unknown location";
//   }
//
//   //tungi
//   //LatLng(23.804475980154823, 90.41485726833344)
//
//   ///first
//   //"lat" : 23.7220806,
//  // "lng" : 90.43066689999999
//   ///
//   ///ontap maniknagar
//   /// LatLng(23.721953954357097, 90.43057098984718)
//
//   Future<String>  getAddressFromLatLng(LatLng position) async {
//     String _host = 'https://maps.google.com/maps/api/geocode/json';
//     final url = '$_host?key=$googleApiKey&language=en&latlng=${position.latitude},${position.longitude}';
//     if(position.latitude != null && position.longitude != null){
//       var response = await http.get(Uri.parse(url));
//       logger.i("resposne..3..${response.body}");
//       if(response.statusCode == 200) {
//         Map data = jsonDecode(response.body);
//         String _formattedAddress = data["results"][0]["formatted_address"];
//         await getLatLngFromAddress(_formattedAddress);
//         print("response ==== $_formattedAddress");
//         return _formattedAddress;
//       } else return "";
//     } else return "";
//   }
//
//   Future<String>  getAddressFromLatLngWithGeoLocatorPackage(Position position) async {
//     String _host = 'https://maps.google.com/maps/api/geocode/json';
//     final url = '$_host?key=$googleApiKey&language=en&latlng=${position.latitude},${position.longitude}';
//     if(position.latitude != null && position.longitude != null){
//       var response = await http.get(Uri.parse(url));
//       logger.i("resposne..3..${response.body}");
//       if(response.statusCode == 200) {
//         Map data = jsonDecode(response.body);
//         String _formattedAddress = data["results"][0]["formatted_address"];
//         await getLatLngFromAddress(_formattedAddress);
//         print("response ==== $_formattedAddress");
//         return _formattedAddress;
//       } else return "";
//     } else return "";
//   }
//
//   Future<LatLng?> getLatLngFromAddress(String address) async {
//     final formattedAddress = Uri.encodeQueryComponent(address);
//     final url = Uri.parse(
//         "https://maps.googleapis.com/maps/api/geocode/json?address=$formattedAddress&key=$googleApiKey");
//     final response = await http.get(url);
//     print("address....$address");
//     logger.i("latlongFromAddress.....${response.body}");
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data["results"].isNotEmpty) {
//         final location = data["results"][0]["geometry"]["location"];
//         final latitude = location["lat"];
//         final longitude = location["lng"];
//         return LatLng(latitude, longitude);
//       } else {
//         print("No location found for this address.");
//         return null;
//       }
//     } else {
//       // Handle errors (e.g., invalid API key, network issues)
//       print("Error fetching location: ${response.statusCode}");
//       return null;
//     }
//   }
//
//
//
//   Future<String> getAddressFromLatLng2(LatLng position) async {
//     try {
//       List<geoLoc.Placemark> placemarks = await geoLoc.placemarkFromCoordinates(position.latitude, position.longitude);
//       logger.i("placemarks: $placemarks");
//       if (placemarks.isNotEmpty) {
//         // Function to calculate the distance between two coordinates
//         double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
//            double distanceValue = Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
//            print("distanceValue....$distanceValue");
//            return distanceValue;
//         }
//
//         // Function to approximate the position from the Placemark details
//         double approximateLatitude(geoLoc.Placemark placemark) {
//           // Use some logic to approximate latitude from the placemark details if available
//           return position.latitude; // Placeholder for actual logic
//         }
//
//         double approximateLongitude(geoLoc.Placemark placemark) {
//           // Use some logic to approximate longitude from the placemark details if available
//           return position.longitude; // Placeholder for actual logic
//         }
//
//         // Find the closest placemark
//         geoLoc.Placemark closestPlacemark = placemarks.reduce((current, next) {
//           print("currentPostion....lat=${position.latitude}....long=${position.longitude}");
//         //  print("next....lat=${current.positon.latitude}....long=${current.longitude}");
//           double currentDistance = calculateDistance(
//               position.latitude,
//               position.longitude,
//               approximateLatitude(current),
//               approximateLongitude(current)
//           );
//           double nextDistance = calculateDistance(
//               position.latitude,
//               position.longitude,
//               approximateLatitude(next),
//               approximateLongitude(next)
//           );
//           print("currentDistance....$currentDistance");
//           print("nextDistance....$nextDistance");
//           return currentDistance < nextDistance ? current : next;
//         });
//
//         return "${closestPlacemark.name}, ${closestPlacemark.locality}, ${closestPlacemark.country}";
//       }
//     } catch (e) {
//       print("Error getting address: $e");
//     }
//     return "Unknown location";
//   }
//
//
//   bool hasUserDeviatedFromPath(LatLng userLocation, List<LatLng> polylinePoints, double deviationThreshold) {
//     for (LatLng point in polylinePoints) {
//       double distance = Geolocator.distanceBetween(
//         userLocation.latitude,
//         userLocation.longitude,
//         point.latitude,
//         point.longitude,
//       );
//       if (distance <= deviationThreshold) {
//         return false;
//       }
//     }
//     return true;
//   }
//
//
//
//   Future<void> _deleteDatabase()async{
//     await SqfLitDb.deleteDatabaseFile();
//   }
//
//   Future<void> deleteTable()async{
//     await SqfLitDb.deleteAnyTableDataFromLocalDb(tableName: "google_map");
//   }
//
//   storeDataInSqflite({double latitude = 0, double longitude = 0})async{
//     String tableName = "google_map";
//     var map = {
//       "latitude": latitude,
//       "longitude": longitude,
//     };
//     String tableInfo =  "CREATE TABLE IF NOT EXISTS $tableName (id TEXT PRIMARY KEY, latitude TEXT, longitude TEXT)";
//     await SqfLitDb.insertDataInTableWithoutBuildINFunction(tableName: tableName, createTableInformation: tableInfo, map: map, databaseName: "google_db");
//   }
//
// }




import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geoLoc;
import 'package:geolocator/geolocator.dart';
import 'package:google_map_live_tracking/utils/app_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../data/repositories/local/sqflite/sqf_lite_db.dart';

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
  dynamic currentLatLongPosition;
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
    super.initState();
  }

  Future<void> initialize() async {
    await clearData();
    await setCustomMarkerIcon();
    await fetchingOnlyCurrentAddress();
  }

  Future<void> clearData() async {
    polyLinesMap = {};
    waypoints = [];
    destination = LatLng(0, 0);
    originLocation = LatLng(0, 0);
    isNeedToRedraw = false;
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  movingMood = "walk";
                  isNeedToRedraw = true;
                });
                updateCurrentLocation();
              },
              child: Text("walking"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  movingMood = "drive";
                  isNeedToRedraw = true;
                });
                updateCurrentLocation();
              },
              child: Text("driving"),
            ),
            TextButton(
              onPressed: () async {
                await fetchCurrentLocation();
              },
              child: Text("my_loca"),
            ),

            if(isTwoPointSame) TextButton(
              onPressed: () async {
              },
              child: Text("two same"),
            ),

          ],
        ),
        body: currentPosition == null
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: startLocationController,
                    //decoration: InputDecoration(hintText: "Start Location"),
                    decoration: InputDecoration(
                      hintText: "Search Starting Location",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async{
                          originSearchResults = await  searchLocations(startLocationController.text);
                          setState(() {

                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.grey,
                    height: 100,
                    width: double.infinity,
                    child:  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: originSearchResults.length,
                        itemBuilder: (context, index) {
                          final result = originSearchResults[index]["description"];
                          //final result = searchResults[index]["description"];
                          return
                            //Text(result.toString());
                            ListTile(
                              title: Text(result.toString()),
                              onTap: () async{
                                // Navigate to the location on the map
                                print("originPlaceId....1");
                                setState(() {
                               //   destinationLatLongPosition = LatLng(result.latitude, result.longitude);
                                  originPlaceId = originSearchResults[index]["place_id"];
                                  print("originPlaceId....$originPlaceId");
                                });
                                dynamic placeDetails = await fetchPlaceDetails(originPlaceId);
                               // currentPosition = LatLng(placeDetails["geometry"]["location"]["lat"], placeDetails["geometry"]["location"]["lng"]);
                                originLocation = LatLng(placeDetails["geometry"]["location"]["lat"], placeDetails["geometry"]["location"]["lng"]);
                                ScaffoldMessenger.of(context).showSnackBar(snackdemo);
                                setState(() {

                                });
                                // completerController.future.then((controller) {
                                //   controller.animateCamera(
                                //     CameraUpdate.newCameraPosition(
                                //       CameraPosition(
                                //         target: LatLng(result.latitude, result.longitude),
                                //         zoom: 14.0,
                                //       ),
                                //     ),
                                //   );
                                // });

                              },
                            );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: destinationController,
                    decoration: InputDecoration(
                      hintText: "Search Destination Location",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async{
                          destinationSearchResults = await searchLocations(destinationController.text);
                          setState(() {

                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    color: Colors.grey,
                    height: 100,
                    width: double.infinity,
                    child:  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: destinationSearchResults.length,
                        itemBuilder: (context, index) {
                          final result = destinationSearchResults[index]["description"];
                          //final result = searchResults[index]["description"];
                          return
                            //Text(result.toString());
                            ListTile(
                              title: Text(result.toString()),
                              onTap: () async{
                                // Navigate to the location on the map
                                setState(() {
                                  //destinationLatLongPosition = LatLng(result.latitude, result.longitude);
                                  destinationPlaceId = destinationSearchResults[index]["place_id"];
                                  print("destinationPlaceId....${destinationPlaceId}");
                                });

                                dynamic placeDetails = await fetchPlaceDetails(destinationPlaceId);
                                destination = LatLng(placeDetails["geometry"]["location"]["lat"], placeDetails["geometry"]["location"]["lng"]);
                                ScaffoldMessenger.of(context).showSnackBar(snackdemo);
                                setState(() {

                                });

                                // completerController.future.then((controller) {
                                //   controller.animateCamera(
                                //     CameraUpdate.newCameraPosition(
                                //       CameraPosition(
                                //         target: LatLng(result.latitude, result.longitude),
                                //         zoom: 14.0,
                                //       ),
                                //     ),
                                //   );
                                // });

                              },
                            );
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                        //  await setRoute();
                         // final coordinateList = await fetchPolylinePointsWithGoogleApi();
                          setState(() {
                            isNeedToRedraw = false;
                          });
                          final coordinateList = await computeRoutes();
                          generatePolyLineFromPoint(coordinateList);
                          await updateCurrentLocation();
                        },
                        child: Text("start"),
                      ),
                      SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () async {
                          await cancelTracking();
                          await clearData();
                          fetchCurrentLocation();
                        },
                        child: Text("end"),
                      ),
                      // SizedBox(width: 20),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     String address = "House no-15/16, kobillya dham residential area,Akbershah, Ferozshah, ঢাকা, Bangladesh";
                      //     getLatLngFromAddress(address);
                      //   },
                      //   child: Text("get lat long"),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GoogleMap(
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
                  Marker(
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
                  });
                },
                onMapCreated: (mapController) {
                  completerController.complete(mapController);
                },
              ),
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
    Position position = await fetchCurrentLocation();
    currentAddress = await getAddressFromLatLng(position);
    setState(() {
      //startLocationController.text = currentAddress;
    });
  }

  Future<Position> fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = LatLng(position.latitude, position.longitude);
    originLocation = LatLng(position.latitude, position.longitude);

    print("firstTimeCurretnLocaton....${logger}");
    logger.i("firstTimeCurretnLocaton....$currentPosition");

    //firstTimeCurretnLocaton....LatLng(23.722151, 90.4306274)
    //getAddressFromLatLng....LatLng(23.7220806,  90.43066689999999)
    //getLatLngFromAddress....LatLng(23.804093,  90.4152376)

    setState(() {});
    return position;
  }

  Future<void> updateCurrentLocation() async {
    await fetchCurrentLocation();

    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async{
      print("listen...");
      currentPosition = LatLng(position.latitude, position.longitude);
      setState(() {});

      bool isSame = areLocationsClose(
        currentLocation: currentPosition!,
        originOrDestinationLocation: originLocation,
        thresholdInMeters: 30,
      );

      print("isSame....$isSame");

      if (isSame){
        isTwoPointSame = true;
        isNeedToRedraw = true;
        originLocation = LatLng(position.latitude, position.longitude);
        //currentAddress = await getAddressFromLatLng(position);
        //final coordinateList = await fetchPolylinePointsWithGoogleApi();
        final coordinateList = await computeRoutes();
        generatePolyLineFromPoint(coordinateList);
        setState(() {});
      } else {
        isTwoPointSame = false;
        if(isNeedToRedraw){
          originLocation = LatLng(position.latitude, position.longitude);
          final coordinateList = await computeRoutes();
          generatePolyLineFromPoint(coordinateList);
        }
        setState(() {});
      }

    });

    // final GoogleMapController googleMapController = await completerController.future;
    // googleMapController.animateCamera(CameraUpdate.newCameraPosition(
    //   CameraPosition(
    //     zoom: 15,
    //     target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
    //   ),
    // ));
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
      'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
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
      'routingPreference': 'TRAFFIC_AWARE_OPTIMAL',
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
          return coordinates.map((point) => LatLng(point.latitude, point.longitude)).toList();
        }
      } else {
        logger.e("Failed to load routes: ${response.body}");
      }
    } catch (e) {
      Logger().e("Error making request: $e");
    }
    return [];
  }



  void generatePolyLineFromPoint(List<LatLng> points) {
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

    Future<String>  getAddressFromLatLng(Position position) async {
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url = '$_host?key=$googleApiKey&language=en&latlng=${position.latitude},${position.longitude}';
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
        currentLatLongPosition = data["results"][0]["geometry"]["location"];
        originPlaceId = data["results"][0]["place_id"].toString();

        print("currentLatLongPostion.....${currentLatLongPosition}");
        await getLatLngFromAddress(_formattedAddress);
        print("response ==== $_formattedAddress");
        return _formattedAddress;
      } else return "";
    } else return "";
  }

    Future<String> getAddressFromLatLng2(Position position) async {
    try {
      List<geoLoc.Placemark> placemarks = await geoLoc.placemarkFromCoordinates(position.latitude, position.longitude);
      logger.i("placemarks: $placemarks");
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return "${placemark.street}, ${placemark.name}, ${placemark.locality}, ${placemark.country}";
      }
    } catch (e) {
      print("Error getting address: $e");
    }
    return "Unknown location";
  }

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
    print("distance....$distance");
    return distance < thresholdInMeters;
  }

  Future<void> cancelTracking() async {
    positionStreamSubscription?.cancel();
    setState(() {
      isUpdateCurrentLocation = false;
    });
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }




  Future<dynamic> searchLocations(String query) async {

    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey';
   // final url = 'https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=$query&key=$googleApiKey';
    print("searchUrl....$url");

    try {
      final response = await http.get(Uri.parse(url));
      logger.i("serachResult....${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;
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

}

