///file just for the map
import 'dart:convert';
import 'game.dart';
import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Database instance = Database();

Set<Marker> markerlist = new Set();


class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);

  final String title;

  _MapPageState createState() => _MapPageState();
}


class _MapPageState extends State<MapPage> {
  GoogleMapController mapController;

  /// original code from  https://codelabs.developers.google.com/codelabs/google-maps-in-flutter/#0
  final LatLng _center = const LatLng(45.521563, -122.677433);

  @override
  void initState(){
    super.initState();

     // Get all the games from the database
      var currentgamesindatabase = instance.getgame();
      print(currentgamesindatabase.length);

      for (int i = 0; i < currentgamesindatabase.length; i++) {
        // Turn each individual game into a game object
        var gameholder = Game.fromMap(currentgamesindatabase.elementAt(i));

        // Add each game one at a time to the map
        markerlist.add(new Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(gameholder.location.latitude, gameholder.location.longitude),
          infoWindow: InfoWindow(title: gameholder.sport),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ));
      }

      // Empty the games
      currentgamesindatabase.clear();

  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    setState(() {

      // Get all the games from the database
      var currentgamesindatabase = instance.getgame();
      print(currentgamesindatabase.length);

      for (int i = 0; i < currentgamesindatabase.length; i++) {
        // Turn each individual game into a game object
        var gameholder = Game.fromMap(currentgamesindatabase.elementAt(i));

        // Add each game one at a time to the map
        markerlist.add(new Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(gameholder.location.latitude, gameholder.location.longitude),
          infoWindow: InfoWindow(title: gameholder.sport),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ));
      }

      // Empty the games
      currentgamesindatabase.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: markerlist,
        ),
      ),
    );
  }
}

///this function pulls the games from the database, creates a list of markers from that list, and returns the list of markers

Marker testmarker = Marker(
  markerId: MarkerId('test'),
  position: LatLng(45.521563, -122.677433),
  infoWindow: InfoWindow(title: 'Test Game'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueOrange,
  ),
);
