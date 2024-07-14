import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_live_tracking/utils/app_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class HomeScreen extends StatefulWidget {
  static const String route = "/HomeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const farmGate = LatLng(23.7568, 90.3901);
  static const ittefagMor = LatLng(23.7220, 90.4214);
  //static LatLng googlePlex = LatLng(-90.0, -122.084);
  static LatLng mountainView = LatLng(-90.0, -122.084);
  //static LatLng destination = LatLng(37.7749, -122.4194);

  final locationController = Location();
  LatLng? currentPosition;
  Map<PolylineId, Polyline> polyLinesMap = {};

  initialize()async{
    await fetchLocationUpdates();
    //fetching polyline points between source to destination
    final coordinateList = await fetchPolylinePoints();
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


  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        appBar:  AppBar(
          title:  const Text("live tracking", maxLines: 1, style: TextStyle(color: Colors.red),),
          backgroundColor: Colors.blue,
        ),
        body: currentPosition == null ? Center(child: CircularProgressIndicator(),) : Column(
          children: [
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
                      icon: BitmapDescriptor.defaultMarker,
                      position: currentPosition!
                  ),
                  const Marker(
                      markerId: MarkerId("sourceLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: ittefagMor
                  ),
                  const Marker(
                      markerId: MarkerId("destinationLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: farmGate
                  ),
                },
                polylines: Set<Polyline>.of(polyLinesMap.values),
              ),
            ),
            ElevatedButton(onPressed: (){}, child: Text("route")),
          ],
        ),
      ),
    );
  }


  //fetch location for updating
  Future<void> fetchLocationUpdates()async{
    bool serviceEnable;
    PermissionStatus permissionStatus;

    //to check service enable status
    serviceEnable = await locationController.serviceEnabled();
    if(serviceEnable){
      serviceEnable = await locationController.requestService();
    }else{
      return;
    }

    //check the permission status
    permissionStatus = await locationController.hasPermission();
    if(permissionStatus == PermissionStatus.denied){
      permissionStatus = await locationController.requestPermission();
      if(permissionStatus != PermissionStatus.granted){
        return;
      }
    }

    //listen or update for location changes
    locationController.onLocationChanged.listen((currentLocation){
      if(currentLocation.latitude != null && currentLocation.longitude != null){
        setState(() {
          currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print("currentPosition..2.$currentPosition");
        });
      }
    });
    locationController.enableBackgroundMode(enable: true);
    print("currentPosition...$currentPosition");
  }

  //fetching polyline points
  Future<List<LatLng>> fetchPolylinePoints() async {
    print("test............1");
    final polylinePoints = PolylinePoints();
    print("test............2");
    final requestValue = PolylineRequest(
      origin: PointLatLng(ittefagMor.latitude, ittefagMor.longitude),
      destination: PointLatLng(farmGate.latitude, farmGate.longitude),
      mode: TravelMode.driving,
      wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
    );
    print("test............3");
    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleApiKey,
        request: requestValue,
      );
      print("test............4");
      if (result.points.isNotEmpty) {
        print("test............5");
        return result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      }
    } catch (error) {
      print("test............6");
      print("Error fetching route: $error");
      // Handle error gracefully, e.g., show a message to the user
    }
    return [];
  }


  //generate polyline from points to generate the path
  Future<void> generatePolyLineFromPoint(List<LatLng> polylineCoordinates)async{
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
  }

}
