import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
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

import '../data/repositories/local/sqflite/sqf_lite_db.dart';
import '../utils/global_classes/color_manager.dart';
import '../utils/global_classes/debounce_class.dart';
import '../utils/global_variable.dart';
import '../widgets/custom_widgets/custom_text_form_field.dart';

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
          // TextButton(
          //   onPressed: () async{
          //     setState(() {
          //       movingMood = "walk";
          //       isNeedToRedraw = true;
          //     });
          //     //updateCurrentLocation();
          //     //await _deleteDatabase();
          //    // updateCurrentLocationWithLocationPackage();
          //   },
          //   child: Text("walking"),
          // ),
          // TextButton(
          //   onPressed: () async{
          //     setState(() {
          //       movingMood = "drive";
          //       isNeedToRedraw = true;
          //     });
          //     //updateCurrentLocation();
          //   //  await _deleteDatabase();
          //     //updateCurrentLocationWithLocationPackage();
          //   },
          //   child: Text("driving"),
          // ),
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
                            child: Row(
                              children: [
                                Text("Set On Map"),
                              ],
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
       // await storeDataInSqflite(latitude: location.latitude!, longitude: location.longitude!);
        Timer(const Duration(seconds: 10), (){
          storeDataInSqflite(latitude: location.latitude!, longitude: location.longitude!);
        });

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
    //print("distance....$distance");
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


}

