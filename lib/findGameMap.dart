import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'globals.dart';
import 'gameDetailsPage.dart';
// Used for determining what type of platform user is on
import 'dart:io' show Platform;

class FindGameMap extends StatefulWidget {
  FindGameMap({Key key, this.title}) : super(key: key);

  final String title;

  _FindGameMapState createState() => _FindGameMapState();
}

class _FindGameMapState extends State<FindGameMap> {
  GoogleMapController mapController;
  // Set of markers that is used by the google Map API to place game locations on map
  Set<Marker> markerlist = new Set();

  bool isIOS = false;

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

    setState(() {
      _userlocation = LatLng(location.location.latitude, location.location.longitude);
    });
  }

  @override
  // Load up the custom marker images on first map build so we can access them
  // Learned how to do this from this link: https://medium.com/flutter-community/ad-custom-marker-images-for-your-google-maps-in-flutter-68ce627107fc
  // The devicepixelratio is being set to match the user screen size which we gather in the global variable
  // global device stats.
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      isIOS = true;
    }

    // Upon initial start of the map check if the user is on IOS

    // if IOS, load the ios pictures
    if (isIOS) {
      BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
              'assets/smalliosBasketball.png')
          .then((onValue) {
        basketball = onValue;
      });
      BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
              'assets/smalliosFootball.png')
          .then((onValue) {
        football = onValue;
      });
      BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
              'assets/smalliosSoccer.png')
          .then((onValue) {
        soccer = onValue;
      });
      BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
              'assets/smalliosBaseball.png')
          .then((onValue) {
        baseball = onValue;
      });
    }
    // Android pictures
    else {
      BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
              'assets/Basketball.png')
          .then((onValue) {
        basketball = onValue;
      });
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(devicePixelRatio: 2.5), 'assets/Football.png')
          .then((onValue) {
        football = onValue;
      });
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(devicePixelRatio: 2.5), 'assets/Soccer.png')
          .then((onValue) {
        soccer = onValue;
      });
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(devicePixelRatio: 2.5), 'assets/Baseball.png')
          .then((onValue) {
        baseball = onValue;
      });
    }

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

// idlist will be used to track which markers have already been created in the map.
  Set<String> idlist = new Set();

  void updatemarkerlist(AsyncSnapshot<QuerySnapshot> snap) {
    // Go through all of the games in the database
    for (int i = 0; i < snap.data.documents.length; i++) {
      // If the markerlist already contains a game with a certain ID, do not add it again
      if (idlist.contains(snap.data.documents.elementAt(i).documentID)) {
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

        // Change the zindex to prevent overlapping issues on markers
        markerzindex++;
        // Add the current game we are adding to the gameid list
        idlist.add(snap.data.documents.elementAt(i).documentID);
        // this game needs to be added to the marker list
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
                            snap.data.documents.elementAt(i).data['sport'] +
                            '.png'),
                        // Need to pull the lat/lng so we can display the actual address
                        title: Text(
                            snap.data.documents
                                .elementAt(i)
                                .data['address']
                                .toString(),
                            style: TextStyle(fontSize: 18)),
                        // In the future, the subtitle will pull values from the DB
                        subtitle: Text(
                            formattedgamedate +
                                '\n' +
                                formattedstarttime +
                                ' to ' +
                                formattedendtime +
                                '\nPlayers needed: ' +
                                snap.data.documents
                                    .elementAt(i)
                                    .data['playersneeded']
                                    .toString(),
                            style: TextStyle(fontSize: 15)),
                        trailing: RaisedButton(
                            onPressed: () {
                              // Navigate to the game detail page
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      // Pass the game ID to the page so we can access data for the specific game
                                      builder: (context) => GameDetailsPage(snap
                                          .data.documents
                                          .elementAt(i)
                                          .documentID)));
                            },
                          textColor: Colors.white,
                          color: Colors.blue,
                            child: Text("Game Info")),
                        isThreeLine: true,
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 16.0),
                      ),
                
                    ],
                  );
                });
          },
          // Set icon to a sport ball
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
            .collection(dbCol)
            // Order in ascending order so we can track which games are older.
            // This is so we can correctly layer the map using zindex on the
            // google map
            .orderBy('endtime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (_userlocation != LatLng(location.location.latitude, location.location.longitude)){
              _getUserLocation();
          } 
          // Any time the snapshot has new data, update the markerlsit
          if (snapshot.hasData) {
            updatemarkerlist(snapshot);
            checkmarkerlist(snapshot);
          }
          else {
            // Show this loading map screen when we are loading in the database data
            return Scaffold(
                body: Container(
                    alignment: Alignment.topCenter,
                    child: Container(
                        padding: EdgeInsets.all(16),
                        child: const CircularProgressIndicator()),
                  ));
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // If the initial position is null, return a container saying that we are loading the map.
            home: _userlocation == null
                ? Scaffold(
                    body: Container(
                    alignment: Alignment.topCenter,
                    child: Container(
                        padding: EdgeInsets.all(16),
                        child: const CircularProgressIndicator()),
                  ),)

                // Once the initial position is not null, create the google map.
                : GoogleMap(
                    onMapCreated: _onMapCreated,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
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
