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

  // The document ids of all the current games in the database will
// go inside this set and be compared to what is in the current markerlist
// to assist with detection and update of game deletion
  Set<String> currentgamesdocidlist = new Set();

// The document ids of all the games in the current marker list
  Set<String> currentmarkeridlist = new Set();

// List that will tell us which markers to remove
  Set<String> markerstoremovelist = new Set();

  // This function cleans up the data from the map that is outdated.
  // It tracks which games have been deleted from the database
  // and need to be deleted from the map marker
  void checkmarkerlist(AsyncSnapshot<QuerySnapshot> snap) {
    // Make the snapshot a map so we can access the document IDs by index
    var docmap = snap.data.documents.asMap();

    // Create a set of document IDs
    for (int i = 0; i < docmap.length; i++) {
      currentgamesdocidlist.add(docmap[i].documentID.toString());
    }
    // Create a set of the IDs that are in the markerlist
    for (int a = 0; a < markerlist.length; a++) {
      currentmarkeridlist
          .add(markerlist.elementAt(a).markerId.value.toString());
    }

    // Use the difference function which returns a set of the differences between
    // the markerIds and the current database document Ids
    markerstoremovelist = currentmarkeridlist.difference(currentgamesdocidlist);

    // Iterate through the markerlist
    for (int j = 0; j < markerlist.length; j++) {
      // Also iterate through the markerstoremovelist
      for (int b = 0; b < markerstoremovelist.length; b++) {
        // If the markerlist has an id value that is in the markerstoremove list
        if (markerlist.elementAt(j).markerId.value.toString() ==
            markerstoremovelist.elementAt(b).toString()) {
          print("REMOVING...");
          print("THIS IS THE ITEM FROM MARKERLIST BEING REMOVED:" +
              markerlist.elementAt(j).markerId.value.toString());
          print(
              "THIS VALUE SHOULD MATCH THE VALUE BEING REMOVED FROM MARKERLIST:" +
                  markerstoremovelist.elementAt(b).toString());
          // We need to remove it from the marker list
          markerlist.remove(markerlist.elementAt(j));
        }
      }
    }

    // Reset all the lists so they are clear and ready for next call.
    markerstoremovelist.clear();
    currentgamesdocidlist.clear();
    currentmarkeridlist.clear();
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
            checkmarkerlist(snapshot);
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
