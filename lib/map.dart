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
import 'package:geolocator/geolocator.dart';
// For global device stats
import 'splashscreen.dart';

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

  // Default that the user does not have location services turned on
  bool locationservices = false;

  // This is the variable that will store the position
  // where the googlemap camera will go to
  static LatLng _userlocation;

// Variables for the custom google marker icons
  BitmapDescriptor football;
  BitmapDescriptor soccer;
  BitmapDescriptor basketball;
  BitmapDescriptor baseball;

// This function gets the users current location using their
// devices location.
// https://stackoverflow.com/questions/57657152/how-to-set-initial-camera-position-to-the-current-devices-latitude-and-longitud
// The above link helped me understand how to do this.
  void _getUserLocation() async {
    _userlocation = null;
    // TODO: Check if user is allowing us to access their location.

    if (locationservices == true) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _userlocation = LatLng(position.latitude, position.longitude);
      });
    } else {
      // TODO: Change this so the user can input a location then have it be translated to latitude and longitude
      setState(() {
        _userlocation = LatLng(45.502800, -122.779533);
      });
    }
  }

  @override
  // Load up the custom marker images on first map build so we can access them
  // Learned how to do this from this link: https://medium.com/flutter-community/ad-custom-marker-images-for-your-google-maps-in-flutter-68ce627107fc
  // The devicepixelratio is being set to match the user screen size which we gather in the global variable
  // global device stats.
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                devicePixelRatio: globaldevicestats.devicePixelRatio),
            'assets/Basketball96.png')
        .then((onValue) {
      basketball = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                devicePixelRatio: globaldevicestats.devicePixelRatio),
            'assets/Football96.png')
        .then((onValue) {
      football = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                devicePixelRatio: globaldevicestats.devicePixelRatio),
            'assets/Soccer96.png')
        .then((onValue) {
      soccer = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                devicePixelRatio: globaldevicestats.devicePixelRatio),
            'assets/Baseball96.png')
        .then((onValue) {
      baseball = onValue;
    });
    // Initialize the current user location on first map build
    _getUserLocation();
  }

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
        var icon;
        // Set the icon based on the proper sport
        if (snap.data.documents.elementAt(i).data['sport'].toString() ==
            'Football') {
          icon = football;
        } else if (snap.data.documents.elementAt(i).data['sport'].toString() ==
            'Basketball') {
          icon = basketball;
        } else if (snap.data.documents.elementAt(i).data['sport'].toString() ==
            'Soccer') {
          icon = soccer;
        } else if (snap.data.documents.elementAt(i).data['sport'].toString() ==
            'Baseball') {
          icon = baseball;
        }
        // If the marker list doesn't contain the game already, then this game needs to be added to the marker list
        markerlist.add(new Marker(
          // Set the markerID as the documentID from the database
          markerId: MarkerId(snap.data.documents.elementAt(i).documentID),
          // Get latitude and longitude from the database
          position: LatLng(
              snap.data.documents.elementAt(i).data['location'].latitude,
              snap.data.documents.elementAt(i).data['location'].longitude),
          // https://stackoverflow.com/questions/54084934/flutter-dart-add-custom-tap-events-for-google-maps-marker
          onTap: () {
            // Here is what happens when a marker is pressed on.
            // The showModalbottom sheet slides up a new view
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    // The sheet will only be as big as its widgets
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        // For now we are just loading the baseball image
                        leading: new Image.asset('assets/Baseball96.png'),
                        // Need to pull the lat/lng so we can display the actual address
                        title: Text('Game at 1023 N Main Street',
                            // The sizing of this ListTile will be determined by FontSize.
                            // We need to play around with fontsize to figure out what
                            // looks best across all devices.
                            style: TextStyle(fontSize: 20)),
                        // In the future, the subtitle will pull values from the DB
                        subtitle: Text(
                            'Thursday, Apr 16, 2020\nFrom 12:30PM to 1:30PM\nPlayers needed: 5\nPlayers currently in game: 5',
                            style: TextStyle(fontSize: 15)),
                        trailing: RaisedButton(
                            onPressed: () {
                              // Navigate to the game detail page
                            },
                            child: Text("View Game Lobby")),
                        isThreeLine: true,
                      ),
                    ],
                  );
                });
          },

          infoWindow:
              // Get the note from the database which for now is being used to display what happens when a user clicks on a particular game
              InfoWindow(
                  title:
                      snap.data.documents.elementAt(i).data['note'].toString()),
          // Default marker is orange
          icon: icon,
        ));
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
        // Only fetch current games
        stream: Firestore.instance
            .collection('Games')
            .where('endtime', isGreaterThan: new DateTime.now())
            .snapshots(),
        builder: (context, snapshot) {
          // Any time the snapshot has new data, update the markerlsit
          if (snapshot.hasData) {
            updatemarkerlist(snapshot);
            checkmarkerlist(snapshot);
          } else {
            // Show this loading map screen when we are loading in the database data
            return MaterialApp(
              home: Scaffold(
                  appBar: AppBar(
                    title: Text('Maps Sample App'),
                    backgroundColor: Colors.green[700],
                  ),
                  body: Container(
                    child: Center(
                      child: Text(
                        'loading map..',
                        style: TextStyle(
                            fontFamily: 'Avenir-Medium',
                            color: Colors.grey[400]),
                      ),
                    ),
                  )),
            );
          }
          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: Text('Maps Sample App'),
                backgroundColor: Colors.green[700],
              ),
              // If the initial position is null, return a container saying that we are loading the map.
              body: _userlocation == null
                  ? Container(
                      child: Center(
                        child: Text(
                          'loading map..',
                          style: TextStyle(
                              fontFamily: 'Avenir-Medium',
                              color: Colors.grey[400]),
                        ),
                      ),
                    )
                  // Once the initial position is not null, create the google map.
                  : GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _userlocation,
                        zoom: 11.0,
                      ),
                      markers: markerlist,
                    ),
            ),
          );
        });
  }
}
