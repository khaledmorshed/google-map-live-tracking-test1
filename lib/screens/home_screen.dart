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
import 'package:location/location.dart' as loc;

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

  final locationController = loc.Location();
  StreamSubscription<loc.LocationData>? locationSubscription;

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
                //updateCurrentLocation();
                updateCurrentLocationWithLocationPackage();
              },
              child: Text("walking"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  movingMood = "drive";
                  isNeedToRedraw = true;
                });
                //updateCurrentLocation();
                updateCurrentLocationWithLocationPackage();
              },
              child: Text("driving"),
            ),
            TextButton(
              onPressed: () async {
                await updateCurrentLocationWithLocationPackage();
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
                                final coordinateList = await computeRoutes();
                                generatePolyLineFromPoint(coordinateList);
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
                          //await updateCurrentLocation();
                          await updateCurrentLocationWithLocationPackage();
                        },
                        child: Text("start"),
                      ),
                      SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () async {
                          await cancelTracking();
                          await clearData();
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
                  if(!isTwoPointSame)Marker(
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
    //Position position = await fetchCurrentLocationWithGeoCoding();
    loc.LocationData position = await fetchCurrentLocationWithLocationPackage();
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

        bool isSame = areLocationsClose(
          currentLocation: currentPosition!,
          originOrDestinationLocation: originLocation,
          thresholdInMeters: 30,
        );

        print("isSame....$isSame");

        if (isSame){
          isTwoPointSame = true;
          isNeedToRedraw = true;
          originLocation = LatLng(location.latitude!, location.longitude!);
          //currentAddress = await getAddressFromLatLng(position);
          //final coordinateList = await fetchPolylinePointsWithGoogleApi();
          final coordinateList = await computeRoutes();
          generatePolyLineFromPoint(coordinateList);
          setState(() {});
        } else {
          isTwoPointSame = false;
          if(isNeedToRedraw){
            originLocation = LatLng(location.latitude!, location.longitude!);
            final coordinateList = await computeRoutes();
            generatePolyLineFromPoint(coordinateList);
          }
          setState(() {});
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

    Future<String>  getAddressFromLatLng(/*Position*/ loc.LocationData position) async {
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

