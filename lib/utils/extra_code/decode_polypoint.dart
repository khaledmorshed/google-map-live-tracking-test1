
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