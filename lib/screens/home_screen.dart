import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geoLoc;
import 'package:geolocator/geolocator.dart';
import 'package:google_map_live_tracking/utils/app_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;

import '../data/repositories/local/sqflite/sqf_lite_db.dart';



class HomeScreen extends StatefulWidget {
  static const String route = "/HomeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //farmegate
  static LatLng destination = LatLng(23.7568, 90.3901);
  //manik nagar
  //23.722312469301194, 90.42867869138718
  //static LatLng destination = LatLng(23.722312469301194, 90.42867869138718);
  //ittefagmor
  static LatLng originLocation = LatLng(23.7220, 90.4214);
  //shapla chattar
  //23.72613053091123, 90.42172338813543
 // static LatLng originLocation = LatLng(23.72613053091123, 90.42172338813543);
  //static LatLng googlePlex = LatLng(-90.0, -122.084);
  static LatLng mountainView = LatLng(-90.0, -122.084);
  //static LatLng destination = LatLng(37.7749, -122.4194);

  final Completer<GoogleMapController> completerController = Completer();
  final locationController = loc.Location();
  //motijheel
  //23.726731821683835, 90.42114805430174
  LatLng? currentPosition;
  Map<PolylineId, Polyline> polyLinesMap = {};
  List<PointLatLng> waypoints = [];
  final changeLatTextEditingController = TextEditingController();
  final changeLongTextEditingController = TextEditingController();
  String movingMood = "driving";
  BitmapDescriptor originIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;
  bool isUpdateCurrentLocation = false;
  bool isTwoPointSame = false;

  final startLocationController = TextEditingController();
  final destinationController = TextEditingController();

  StreamSubscription<loc.LocationData>? locationSubscription;
  String currentAddress = "";


  initialize()async{
    // startLocationController.text = "mohakhali, dhaka";
    // destinationController.text = "farmgate, dhaka";
    ///await _deleteDatabase();
    await clearData();
    await setCustomMarkerIcon();
    await fetchCurrentLocation();
    //fetching polyline points between source to destination
    //final coordinateList = await fetchPolylinePointsWithDirectionApi();
    final coordinateList = await fetchPolylinePointsWithRouteApi();
    //make path with the coordinate point between source to destination
    generatePolyLineFromPoint(coordinateList);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      initialize();
    });
    super.initState();
  }

  clearData()async{
    polyLinesMap = {};
    waypoints = [];
    destination = LatLng(0, 0);
    originLocation = LatLng(0, 0);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
   // print("ccurrentPosition....build...$currentPosition");
    return  SafeArea(
      child: Scaffold(
        appBar:  AppBar(
         // title:  const Text("tracking", maxLines: 1, style: TextStyle(color: Colors.red),),
          backgroundColor: Colors.blue,
          actions: [
            TextButton(onPressed: (){
              setState(() {
                movingMood = "walking";
              });
              updateCurrentLocation();
            }, child: Text("walking")),
            TextButton(onPressed: (){
              setState(() {
                movingMood = "driving";
              });
              updateCurrentLocation();
            }, child: Text("driving")),
            TextButton(onPressed: ()async{
              //updateCurrentLocation();
              await fetchCurrentLocation();
            }, child: Text("my_loca")),
            // if(isTwoPointSame)TextButton(onPressed: (){
            //
            // }, child: Text("two")),

          ],
        ),
        body: currentPosition == null ? Center(child: CircularProgressIndicator(),) : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: startLocationController,
                    decoration: InputDecoration(hintText: "Start Location"),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: destinationController,
                    decoration: InputDecoration(hintText: "Destination"),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: ()async{
                        //  await fetchCurrentLocation();
                         // await updateCurrentLocation();
                          await setRoute();
                          await updateCurrentLocation();
                        },
                        child: Text("start"),
                      ),
                      SizedBox(width: 30,),
                      ElevatedButton(
                        onPressed: ()async{
                          await cancelTracking();
                          await clearData();
                          fetchCurrentLocation();
                        },
                        child: Text("end"),
                      ),
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
                      position: currentPosition!
                  ),
                   /*if(!isUpdateCurrentLocation)*/Marker(
                      markerId: MarkerId("sourceLocation"),
                      icon: originIcon,
                      position: originLocation
                  ),
                   Marker(
                      markerId: MarkerId("destinationLocation"),
                      icon: destinationIcon,
                      position: destination
                  ),
                },
                polylines: Set<Polyline>.of(polyLinesMap.values),
               //  polylines: {
               //
               //  },
                onTap: (LatLng tappedPoint) {
                  print("tappedPoint...${tappedPoint}");
                  setState(() {
                    waypoints.add(PointLatLng(tappedPoint.latitude, tappedPoint.longitude));
                  });
                },
                onMapCreated: (mapController){
                  completerController.complete(mapController);
                },
              ),
            ),

            // TextFormField(
            //   controller: changeLatTextEditingController,
            //   decoration: InputDecoration(
            //       hintText: "lat"
            //   ),
            // ),
            // SizedBox(height: 10,),
            // TextFormField(
            //   controller: changeLongTextEditingController,
            //   decoration: InputDecoration(
            //       hintText: "long"
            //   ),
            // ),

            // ElevatedButton(onPressed: ()async{
            //
            // }, child: Text("change route")),

          ],
        ),
      ),
    );
  }

  //marker
  Future<void> setCustomMarkerIcon()async{
    BitmapDescriptor.asset(ImageConfiguration(size: Size(40, 40)), "assets/icons/origin.png").then((icon){
      originIcon = icon;
    });
    BitmapDescriptor.asset(ImageConfiguration(size: Size(40, 40)), "assets/icons/destination.png").then((icon){
      destinationIcon = icon;
    });
    BitmapDescriptor.asset( ImageConfiguration(size: Size(50, 50)), "assets/icons/current.png").then((icon){
      currentIcon = icon;
    });
    setState(() {

    });
  }


  //fetch location for updating
  Future<void> fetchCurrentLocation()async{
    try{
      bool serviceEnable;
      loc.PermissionStatus permissionStatus;

      //to check service enable status
      serviceEnable = await locationController.serviceEnabled();
      if(serviceEnable){
        serviceEnable = await locationController.requestService();
      }else{
        return;
      }

      //check the permission status
      permissionStatus = await locationController.hasPermission();
      if(permissionStatus == loc.PermissionStatus.denied){
        permissionStatus = await locationController.requestPermission();
        if(permissionStatus != loc.PermissionStatus.granted){
          return;
        }
      }

      //first time get location
      await locationController.getLocation().then((location)async{
        currentPosition = LatLng(location.latitude!, location.longitude!);
        //currentPosition =LatLng(23.726731821683835, 90.42114805430174);
        // Reverse geocode to get address
        currentAddress = await getAddressFromLatLng(currentPosition!);
        startLocationController.text = currentAddress;
        setState(() {

        });
      });
    }catch(err){
      print("err...$err");
    }
  }

  //fetch location for updating
  Future<void> updateCurrentLocation()async{
    try{
      bool serviceEnable;
      loc.PermissionStatus permissionStatus;

      //to check service enable status
      serviceEnable = await locationController.serviceEnabled();
      if(serviceEnable){
        serviceEnable = await locationController.requestService();
      }else{
        return;
      }

      //check the permission status
      permissionStatus = await locationController.hasPermission();
      if(permissionStatus == loc.PermissionStatus.denied){
        permissionStatus = await locationController.requestPermission();
        if(permissionStatus != loc.PermissionStatus.granted){
          return;
        }
      }

      //first time get location
      await locationController.getLocation().then((location){
        currentPosition = LatLng(location.latitude!, location.longitude!);
        //currentPosition =LatLng(23.726731821683835, 90.42114805430174);
        setState(() {

          Timer(const Duration(seconds: 2), ()async{
            //isUpdateCurrentLocation = true;
            setState(() {

            });
          });
        });
      });

      final GoogleMapController googleMapController = await completerController.future;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 15,
            target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          )
      ));
      //listen or update for location changes
      locationSubscription = locationController.onLocationChanged.listen((currentLocation)async{
        if(currentLocation.latitude != null && currentLocation.longitude != null){
       //   originLocation =  LatLng(currentLocation.latitude!, currentLocation.longitude!);
          currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
         // await storeDataInSqflite(latitude: currentLocation.latitude!, longitude: currentLocation.longitude!);


          if (!areLocationsClose(currentLocation: currentPosition!, originOrDestinationLocation: originLocation, thresholdInMeters: 50)) {
            //originLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            currentPosition =LatLng(currentLocation.latitude!, currentLocation.longitude!);
            setState(() {//
              isTwoPointSame = true;//
            });
            print("yes.....in......close");
          }else{
            isTwoPointSame = false;
            setState(() {
              print("no.....in......close");
            });
          }

          setState(() {
          });

          Timer(const Duration(seconds: 2), ()async{
            final coordinateList = await fetchPolylinePointsWithRouteApi();
            generatePolyLineFromPoint(coordinateList);
          });

            // googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            //     CameraPosition(
            //       zoom: 15,
            //       target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
            //     )
            // ));
            print("currentPosition..2.$currentPosition");

        }
      });
      locationController.enableBackgroundMode(enable: true);
      print("currentPosition...$currentPosition");
    }catch(err){
      print("err...$err");
    }
  }

  //fetching polyline points
  Future<List<LatLng>> fetchPolylinePointsWithDirectionApi() async {

    // final List<PointLatLng> waypoints = [
    //   // Add intermediate waypoints if needed
    //   //PointLatLng(23.7406, 90.3925), // Example waypoint
    // ];

    final polylinePoints = PolylinePoints();
    final requestValue = PolylineRequest(
      origin: PointLatLng(originLocation.latitude, originLocation.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      mode: TravelMode.driving,
      //wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
     // wayPoints: waypoints.map((wp) => PolylineWayPoint(location: "${wp.latitude},${wp.longitude}")).toList(),
    );
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleApiKey,
        request: requestValue,
      );
      if (result.points.isNotEmpty) {
        return result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      }
    } catch (error) {
      print("Error fetching route: $error");
      // Handle error gracefully, e.g., show a message to the user
    }
    return [];
  }


  Future<List<LatLng>> fetchPolylinePointsWithRouteApi() async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?"
            "origin=${originLocation.latitude},${originLocation.longitude}"
            "&destination=${destination.latitude},${destination.longitude}"
            "&mode=$movingMood"
            "&waypoints=${waypoints.map((wp) => "${wp.latitude},${wp.longitude}").join(',')}" // Add waypoints if needed
            "&key=${googleApiKey}");
    try{
      final response = await http.get(url);
      print("response.....3+${response}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final routes = jsonResponse['routes'] as List;

        if (routes.isNotEmpty) {
          final points = routes[0]['overview_polyline']['points'] as String;
          final coordinates = PolylinePoints().decodePolyline(points);
          return coordinates.map((point) => LatLng(point.latitude, point.longitude)).toList();
        }
      } else {
        print("Error fetching route: ${response.statusCode}"); // Handle error
      }
    }catch(err){
      print("catch Error : $err");
      return [];
    }
    return [];
  }



  //generate polyline from points to generate the path
  Future<void> generatePolyLineFromPoint(List<LatLng> polylineCoordinates)async{
    //print("polylineCoordinates...${polylineCoordinates}");
  //   const id = PolylineId("polyline");
  //   final polyline = Polyline(
  //     polylineId: id,
  //     color: Colors.blueAccent,
  //     points: polylineCoordinates,
  //     width: 5,
  //   );
  //   setState(() {
  //     polyLinesMap[id] = polyline;
  //   });

    const id = PolylineId("polyline");
    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polyLinesMap[id] = polyline;
    });

    // Separate completed and remaining path
    List<LatLng> completedPolylineCoordinates = [];
    List<LatLng> remainingPolylineCoordinates = [];
    bool completedSegment = true;

    for (LatLng point in polylineCoordinates) {
      if (completedSegment && Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        point.latitude,
        point.longitude,
      ) < 20) {
        completedPolylineCoordinates.add(point);
      } else {
        completedSegment = false;
        remainingPolylineCoordinates.add(point);
      }
    }

    const completedId = PolylineId("completed_polyline");
    final completedPolyline = Polyline(
      polylineId: completedId,
      color: Colors.green,
      points: completedPolylineCoordinates,
      width: 5,
    );

    const remainingId = PolylineId("remaining_polyline");
    final remainingPolyline = Polyline(
      polylineId: remainingId,
      color: Colors.blueAccent,
      points: remainingPolylineCoordinates,
      width: 5,
    );

    setState(() {
      polyLinesMap[completedId] = completedPolyline;
      polyLinesMap[remainingId] = remainingPolyline;
    });

    // Debug print to check polyline coordinates
   // print("Completed Polyline Coordinates: $completedPolylineCoordinates");
    //print("Remaining Polyline Coordinates: $remainingPolylineCoordinates");

  }


  Future<void> setRoute() async {
    try{
      if (startLocationController.text.isNotEmpty &&
          destinationController.text.isNotEmpty) {
        List<geoLoc.Location> startPlacemark = await geoLoc.locationFromAddress(startLocationController.text);
        print("startPlacemark...${startPlacemark}");
        List<geoLoc.Location> destinationPlacemark = await geoLoc.locationFromAddress(destinationController.text);
        print("destinationPlacemark...${destinationPlacemark}");

        if (startPlacemark.isNotEmpty && destinationPlacemark.isNotEmpty) {
          originLocation = LatLng(startPlacemark[0].latitude, startPlacemark[0].longitude);
          destination = LatLng(destinationPlacemark[0].latitude, destinationPlacemark[0].longitude);

          setState(() {
            isUpdateCurrentLocation = false;
          });
          // Fetching polyline points between source to destination
          final coordinateList = await fetchPolylinePointsWithRouteApi();
          // Make path with the coordinate points between source to destination
          generatePolyLineFromPoint(coordinateList);
        }
      }
    }catch(err){
      print("find error....$err");
    }
  }

  // Cancel tracking
  Future<void> cancelTracking() async{
    locationSubscription?.cancel();  // Cancel the subscription
    locationController.enableBackgroundMode(enable: false);  // Disable background mode
  }


  bool areLocationsClose({required LatLng currentLocation, required LatLng originOrDestinationLocation, double thresholdInMeters = 1.0}) {
    double distanceInMeters = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      originOrDestinationLocation.latitude,
      originOrDestinationLocation.longitude,
    );
    return distanceInMeters <= thresholdInMeters;
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      List<geoLoc.Placemark> placemarks = await geoLoc.placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return "${placemark.street}, ${placemark.locality}, ${placemark.country}";
      }
    } catch (e) {
      print("Error getting address: $e");
    }
    return "Unknown location";
  }


  Future<void> _deleteDatabase()async{
    await SqfLitDb.deleteDatabaseFile();
  }

  Future<void> deleteTable()async{
    await SqfLitDb.deleteAnyTableDataFromLocalDb(tableName: "google_map");
  }

  storeDataInSqflite({double latitude = 0, double longitude = 0})async{
    String tableName = "google_map";
    var map = {
      "latitude": latitude,
      "longitude": longitude,
    };
    String tableInfo =  "CREATE TABLE IF NOT EXISTS $tableName (id TEXT PRIMARY KEY, latitude TEXT, longitude TEXT)";
    await SqfLitDb.insertDataInTableWithoutBuildINFunction(tableName: tableName, createTableInformation: tableInfo, map: map, databaseName: "google_db");
  }

}
