import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_map_live_tracking/utils/app_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../data/repositories/local/sqflite/sqf_lite_db.dart';
import '../utils/global_variable.dart';

class ShowTrackedScreen extends StatefulWidget {
  static const String route = "/ShowTrackedScreen";
  const ShowTrackedScreen({super.key});

  @override
  State<ShowTrackedScreen> createState() => _ShowTrackedScreenState();
}

class _ShowTrackedScreenState extends State<ShowTrackedScreen> {
  bool isLoading = true;
  static LatLng destination = LatLng(0, 0);
  static LatLng originLocation = LatLng(0, 0);
  Map<PolylineId, Polyline> polyLinesMap = {};
  final Completer<GoogleMapController> completerController = Completer();
  int len = 0;
  var logger = Logger();
  List<LatLng> nearestRoadRoutePoints = [];

  initialize()async{
    setState(() {
      isLoading = true;
    });
    dynamic latLongList =  await SqfLitDb.getAnyTableDataFromLocalDbWitPassingOnlyTableName(tableName: tableName, databaseName: databaseName);
    len = latLongList.length;
    print("latLongLIst...$latLongList");
    int lastLen = len - 1;
    if(lastLen > 0){
      originLocation = LatLng(double.parse(latLongList[0]["latitude"]), double.parse(latLongList[0]["longitude"]));
      destination = LatLng(double.parse(latLongList[lastLen]["latitude"]), double.parse(latLongList[lastLen]["longitude"]));
    }

   // final routeListTemp = latLongList.map((value)=>LatLng(double.parse(value["latitude"]), double.parse(value["longitude"]))) as   List<LatLng>;
    List<LatLng> routeList = [];
    routeList = latLongList.map((value)=>LatLng(double.parse(value["latitude"]), double.parse(value["longitude"]))).toList().cast<LatLng>();


    // for(int i=0; i<=lastLen; i++){
    //   final value = LatLng(double.parse(latLongList[i]["latitude"])+0.001, double.parse(latLongList[i]["longitude"])+0.002);
    //   routeList.add(value);
    //   // if(i==lastLen/2){
    //   //   final value = LatLng(double.parse(latLongList[i]["latitude"])+0.00991, double.parse(latLongList[i]["longitude"])+0.0191);
    //   //   routeList.add(value);
    //   // }
    //   // else if(i==lastLen/3){
    //   //   final value = LatLng(double.parse(latLongList[i]["latitude"])+0.0091, double.parse(latLongList[i]["longitude"])+0.0092);
    //   //   routeList.add(value);
    //   // }else if(i==lastLen/5){
    //   //   final value = LatLng(double.parse(latLongList[i]["latitude"])+0.0074, double.parse(latLongList[i]["longitude"])+0.0095);
    //   //   routeList.add(value);
    //   // }
    //   // else if(i%2 == 1){
    //   //   final value = LatLng(double.parse(latLongList[i]["latitude"])+0.001, double.parse(latLongList[i]["longitude"])+0.003);
    //   //   routeList.add(value);
    //   // }else{
    //   //   final value = LatLng(double.parse(latLongList[i]["latitude"])+0.005, double.parse(latLongList[i]["longitude"])+0.002);
    //   //   routeList.add(value);
    //   // }
    // }

     String points = '60.170880,24.942795|60.170879,24.942796|60.170877,24.942796';

     points = latLongList.map((value) {
      String latlong = "${value["latitude"]},${value["longitude"]}";
      return latlong;
    }).join('|');


    List<LatLng> snappedPoints = [];

    for (int i = 0; i < routeList.length; i += 99) {
      String points = routeList.skip(i).take(99).map((value) => "${value.latitude},${value.longitude}").join('|');
      List<LatLng> batchSnappedPoints = await fetchNearestRoads(points: points);
      snappedPoints.addAll(batchSnappedPoints);
    }

  //  nearestRoadRoutePoints =  await fetchNearestRoads(points: points);

    //List<LatLng> routeList = routeListTemp;
    await generatePolyLineFromPoint(points: routeList, polyId: "originalRoad", color: Colors.red);
    await generatePolyLineFromPoint(points: snappedPoints, polyId: "snapARoad", color: Colors.green);
    completerController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(originLocation.latitude, originLocation.longitude),
            zoom: 14.0,
          ),
        ),
      );
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_){
      initialize();
    });
    super.initState();
  }

  var snackdemo = SnackBar(
    content: Text('success'),
    backgroundColor: Colors.green,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(5),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("path"),
        actions: [
          Text("$len"),
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(),) : len == 0 ? Center(child: Text("No path found"),) : Column(
        children: [
          Container(
            height: 600,
            child: GoogleMap(
              myLocationEnabled: false,
              initialCameraPosition: CameraPosition(
                target: originLocation,
                zoom: 13,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("sourceLocation"),
                  //icon: originIcon,
                  position: originLocation,
                ),
                Marker(
                  markerId: MarkerId("destinationLocation"),
                  //icon: destinationIcon,
                  position: destination,
                ),
              },
              polylines: Set<Polyline>.of(polyLinesMap.values),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> generatePolyLineFromPoint({List<LatLng> points = const[], String polyId = "route1",
    Color color = Colors.yellow}) async{
    final PolylineId polylineId = PolylineId(polyId);
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      color: color,
      points: points,
      width: 5,
    );

    polyLinesMap[polylineId] = polyline;

  }

  Future<List<LatLng>> fetchNearestRoads({String points = ""}) async {

    //final String baseUrl = 'https://roads.googleapis.com/v1/nearestRoads';
    final String baseUrl = 'https://roads.googleapis.com/v1/snapToRoads';

    //final Uri url = Uri.parse('$baseUrl?points=$points&key=$googleApiKey');
    final Uri url = Uri.parse('$baseUrl?path=$points&interpolate=true&key=$googleApiKey');
    logger.i("url..$url");

    try {
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        //final Map<String, dynamic> data = jsonDecode(response.body);
        final data = jsonDecode(response.body);
        logger.i("response..${response.body}");
        final routes = data['snappedPoints'] as List;
        logger.i("route..$routes");
       // nearestRoadRoutePoints = routes.map((value) => LatLng(double.parse(value["location"]["latitude"]), double.parse(value["location"]["longitude"]))).toList();
        nearestRoadRoutePoints = routes.map((value){
              print("value...${value["location"]["latitude"]}");
              return LatLng(double.parse(value["location"]["latitude"].toString()), double.parse(value["location"]["longitude"].toString()));
            }).toList();
        print("nearestRoadRoutePoints..${nearestRoadRoutePoints}");

        return nearestRoadRoutePoints;
        // Process the data as needed
      } else {
        logger.e("Failed to load routes: ${response.body}");
      }
    } catch (e) {
      Logger().e("Error making request: $e");
    }
    return [];
  }

}




