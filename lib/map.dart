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

// Set of markers that is used by the google Map API to place game locations on map
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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

// This function takes in a snapshot generated from a streambuilder
// that allows for constant listening of new datachanges to the database.
// The function takes in this streambuilder data and accesses location
// and properties for each game in our database. Then, it takes the data and creates
// new markers to put on our google map to represent all the games in our database.
  void updatemarkerlist(AsyncSnapshot<QuerySnapshot> snap) {
    // Go through all of the games in the database
    for (int i = 0; i < snap.data.documents.length; i++) {
      // If the markerlist already contains a game with a certain ID, do not add it again
      if (markerlist.contains(snap.data.documents.elementAt(i).documentID)) {
        break;
      } else {
        // If the marker list doesn't contain the game already, then this game needs to be added to the marker list
        markerlist.add(new Marker(
            // Set the markerID as the documentID from the database
            markerId: MarkerId(snap.data.documents.elementAt(i).documentID),
            // Get latitude and longitude from the database
            position: LatLng(
                snap.data.documents.elementAt(i).data['location'].latitude,
                snap.data.documents.elementAt(i).data['location'].longitude),
            infoWindow:
                // Get the note from the database which for now is being used to display what happens when a user clicks on a particular game
                InfoWindow(
                    title: snap.data.documents
                        .elementAt(i)
                        .data['note']
                        .toString()),
            // Default marker is orange
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We create the streambuilder here to allow us to constantly listen in to changes to the Games
    // database. The materialApp is wrapped inside the streambuilder so we can update data that is used
    // in the materialApp.
    return new StreamBuilder(
        stream: Firestore.instance.collection('Games').snapshots(),
        builder: (context, snapshot) {
          // Any time the snapshot has new data, update the markerlsit
          if (snapshot.hasData) {
            updatemarkerlist(snapshot);
          } else {
            return new Text('Loading...');
          }
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
        });
  }
}
