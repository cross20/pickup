///This file is everything in map.dart, just no longer has the Scaffold/Material App Widget
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
import 'package:geocoder/geocoder.dart';
import 'package:fluster/fluster.dart';
import 'package:meta/meta.dart';
import 'gamedetails.dart';

Database instance = Database();

class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  final BitmapDescriptor icon;
  MapMarker({
    @required this.id,
    @required this.position,
    @required this.icon,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
  }) : super(
          markerId: id,
          latitude: position.latitude,
          longitude: position.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );
  Marker toMarker() => Marker(
        markerId: MarkerId(id),
        position: LatLng(
          position.latitude,
          position.longitude,
        ),
        icon: icon,
      );
}

// Set of markers that is used by the google Map API to place game locations on map
Set<Marker> markerlist = new Set();

Set<MapMarker> clusterlist = new Set();

class FindGameMap extends StatefulWidget {
  FindGameMap({Key key, this.title}) : super(key: key);

  final String title;

  _FindGameMapState createState() => _FindGameMapState();
}

class _FindGameMapState extends State<FindGameMap> {
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
                devicePixelRatio: 2.5),
            'assets/Basketball96.png')
        .then((onValue) {
      basketball = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                devicePixelRatio: 2.5),
            'assets/Football96.png')
        .then((onValue) {
      football = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                devicePixelRatio: 2.5),
            'assets/Soccer96.png')
        .then((onValue) {
      soccer = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                devicePixelRatio: 2.5),
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

// This is the variable that will track the zindex for the google map markers.
// The zindex determines what marker will take priority when there are overlapping
// markers on the map. 
  double markerzindex = 0;

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
        // Change the z index
        markerzindex++;
        // If the marker list doesn't contain the game already, then this game needs to be added to the marker list
        markerlist.add(new Marker(
          // Set the markerID as the documentID from the database
          markerId: MarkerId(snap.data.documents.elementAt(i).documentID),
          // Get latitude and longitude from the database
          position: LatLng(
              snap.data.documents.elementAt(i).data['location'].latitude,
              snap.data.documents.elementAt(i).data['location'].longitude),
          zIndex: markerzindex,
          // https://stackoverflow.com/questions/54084934/flutter-dart-add-custom-tap-events-for-google-maps-marker
          onTap: () {
            // https://stackoverflow.com/questions/16126579/how-do-i-format-a-date-with-dart

            // Get dates ready for displaying on icon tap
            DateTime gamedate =
                snap.data.documents.elementAt(i).data['starttime'].toDate();
            var gamedateformatter = new DateFormat('yMMMMEEEEd');
            String formattedgamedate = gamedateformatter.format(gamedate);

            DateTime starttime =
                snap.data.documents.elementAt(i).data['starttime'].toDate();
            starttime = starttime.toLocal();
            var starttimeformatter = new DateFormat("jm");
            String formattedstarttime = starttimeformatter.format(starttime);

            DateTime endtime =
                snap.data.documents.elementAt(i).data['endtime'].toDate();
            endtime = endtime.toLocal();
            var endtimeformatter = new DateFormat("jm");
            String formattedendtime = endtimeformatter.format(endtime);
  
            // The showModalbottom sheet slides up a new view
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    // The sheet will only be as big as its widgets
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        // Load the correct image
                        leading: new Image.asset('assets/' +
                            snap.data.documents
                                .elementAt(i)
                                .data['sport']
                                .toString() +
                            '.png'),
                        // Need to pull the lat/lng so we can display the actual address
                        title: Text(
                            snap.data.documents
                                .elementAt(i)
                                .data['address']
                                .toString(),
                            // TODO: The sizing of this ListTile will be determined by FontSize.
                            // TODO: We need to play around with fontsize to figure out what
                            // looks best across all devices.
                            style: TextStyle(fontSize: 20)),
                        // In the future, the subtitle will pull values from the DB
                        subtitle: Text(
                            formattedgamedate +
                                '\nFrom ' +
                                formattedstarttime +
                                ' to ' +
                                formattedendtime +
                                '\nPlayers needed: ' +
                                snap.data.documents
                                    .elementAt(i)
                                    .data['playersneeded']
                                    .toString() +
                                // TODO: Implement players currently in the game once this feature is complete
                                // by someone else.
                                '\nPlayers in game: need to implement ',
                            style: TextStyle(fontSize: 15)),
                        trailing: RaisedButton(
                            onPressed: () {
                              // Navigate to the game detail page
                              Navigator.push(
                                context, MaterialPageRoute(             // Pass the game ID to the page so we can access data for the specific game
                                  builder: (context) => GameDetailsPage(snap.data.documents.elementAt(i).documentID))
                              );
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

  _coordinatetoaddress(GeoPoint gamelocation, var address) async {
    final coordinates =
        new Coordinates(gamelocation.latitude, gamelocation.longitude);
    address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    address = address.first;
  }

  @override
  Widget build(BuildContext context) {
    // We create the streambuilder here to allow us to constantly listen in to changes to the Games
    // database. The materialApp is wrapped inside the streambuilder so we can update data that is used
    // in the materialApp.
    return new StreamBuilder(
        // Only fetch current games
        stream: Firestore.instance
            .collection('TestCollectionForMaps')
            .where('endtime', isGreaterThan: new DateTime.now())
            // Order in ascending order so we can track which games are older.
            // This is so we can correctly layer the map using zindex on the
            // google map
            .orderBy('endtime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          // Any time the snapshot has new data, update the markerlsit
          if (snapshot.hasData) {
            updatemarkerlist(snapshot);
            checkmarkerlist(snapshot);
          } else {
            // Show this loading map screen when we are loading in the database data
            return MaterialApp(
                  home: Container(
                    child: Center(
                      child: Text(
                        'loading map..',
                        style: TextStyle(
                            fontFamily: 'Avenir-Medium',
                            color: Colors.grey[400]),
                      ),
                    ),
                  ),
            );
          }
          return MaterialApp(
              // If the initial position is null, return a container saying that we are loading the map.
              home: _userlocation == null
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
          );
        });
  }
}
