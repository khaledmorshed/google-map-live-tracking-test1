import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  initialize()async{
    setState(() {
      isLoading = true;
    });
    dynamic latLongList =  await SqfLitDb.getAnyTableDataFromLocalDbWitPassingOnlyTableName(tableName: tableName, databaseName: databaseName);
    len = latLongList.length;
    int lastLen = len - 1;
    if(lastLen > 0){
      originLocation = LatLng(double.parse(latLongList[0]["latitude"]), double.parse(latLongList[0]["longitude"]));
      destination = LatLng(double.parse(latLongList[lastLen]["latitude"]), double.parse(latLongList[lastLen]["longitude"]));
    }

   // final routeListTemp = latLongList.map((value)=>LatLng(double.parse(value["latitude"]), double.parse(value["longitude"]))) as   List<LatLng>;
    List<LatLng> routeList = latLongList.map((value)=>LatLng(double.parse(value["latitude"]), double.parse(value["longitude"]))).toList().cast<LatLng>();
    //List<LatLng> routeList = routeListTemp;
    await generatePolyLineFromPoint(routeList);
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
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_){
      initialize();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("path"),
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(),) : len == 0 ? Center(child: Text("No path found"),) : Column(
        children: [
          Container(
            height: 300,
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

  Future<void> generatePolyLineFromPoint(List<LatLng> points) async{
    final PolylineId polylineId = PolylineId("route");
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      color: Colors.blue,
      points: points,
      width: 5,
    );

    polyLinesMap[polylineId] = polyline;
    setState(() {
      isLoading = false;
    });
  }
}




