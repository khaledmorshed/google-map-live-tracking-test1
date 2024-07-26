
// List<LatLng> _decodePolyline(String polyline) {
//   List<LatLng> points = [];
//   int index = 0, len = polyline.length;
//   int lat = 0, lng = 0;
//
//   while (index < len) {
//     int b, shift = 0, result = 0;
//     do {
//       b = polyline.codeUnitAt(index++) - 63;
//       result |= (b & 0x1f) << shift;
//       shift += 5;
//     } while (b >= 0x20);
//     int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lat += dlat;
//
//     shift = 0;
//     result = 0;
//     do {
//       b = polyline.codeUnitAt(index++) - 63;
//       result |= (b & 0x1f) << shift;
//       shift += 5;
//     } while (b >= 0x20);
//     int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lng += dlng;
//
//     points.add(LatLng(lat / 1E5, lng / 1E5));
//   }
//
//   return points;
// }



//fetch polyline code with direction api
/*
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
 */



/*
boddy

    Column(
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
                          await cancelTracking();
                          await _deleteDatabase();
                          setState(() {
                            isNeedToRedraw = false;
                          });
                          final coordinateList = await computeRoutes();
                          await generatePolyLineFromPoint(coordinateList);
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
            ),
          ],
        ),
 */