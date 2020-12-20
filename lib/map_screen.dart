import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'network_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  String fname;
  String lname;
  String email;
  String imageUrl;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon_v2.png");
    return byteData.buffer.asUint8List();
  }

  void getProfileData() async {
    dynamic proData = await fetchData();
    setState(() {
      fname = proData['first_name'];
      lname = proData['last_name'];
      email = proData['email'];
      imageUrl = proData['avatar'];
    });
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                          radius: 100,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text('First Name : $fname'),
                        Text('Last Name : $lname'),
                        Text('Email Address : $email'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(fontSize: 17.0),
                        ))
                  ],
                );
              },
            );
          },
          markerId: MarkerId("car"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription = _locationTracker.onLocationChanged.listen(
        (newLocalData) {
          if (_controller != null) {
            _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    bearing: 192.8334901395799,
                    target:
                        LatLng(newLocalData.latitude, newLocalData.longitude),
                    tilt: 0,
                    zoom: 18),
              ),
            );
            updateMarkerAndCircle(newLocalData, imageData);
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
    getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map Demo'),
        centerTitle: true,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        markers: Set.of((marker != null) ? [marker] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        zoomControlsEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_searching),
        onPressed: () {
          getCurrentLocation();
        },
      ),
    );
  }
}
