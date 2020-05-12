import 'package:flutter/material.dart';
import 'appUI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'globals.dart';

class GameDetailsPage extends StatefulWidget {
  // This variable will store the gameid
  // for the specific game we are displaying the details for.
  // This game id will be used to query for vital game information.
  final String gameid;

  // var gamedateformatter = new DateFormat('yMMMMEEEEd');
  // String formattedgamedate = gamedateformatter.format(gamedate);

  // var starttimeformatter = new DateFormat("jm");
  // String formattedstarttime = starttimeformatter.format(starttime);

  // DateTime endtime =
  //     snap.data.documents.elementAt(i).data['endtime'].toDate();
  // endtime = endtime.toLocal();
  // var endtimeformatter = new DateFormat("jm");
  // String formattedendtime = endtimeformatter.format(endtime);

  GameDetailsPage(this.gameid);

  @override
  _GameDetailsPageState createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  
  void _getUserLocation() async {
    DocumentSnapshot query = await Firestore.instance
        .collection(dbCol)
        .document(widget.gameid)
        .get();
    // TODO: Change this so the user can input a location then have it be translated to latitude and longitude
    setState(() {
      _center = LatLng(
          query.data['location'].latitude, query.data['location'].longitude);

         
    });

  }

  Game currentgame;

  GoogleMapController _controller;

  static LatLng _center;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Set<Marker> markerlist = new Set();

  var gamedateformatter = new DateFormat('yMMMMEEEEd');

  var starttimeformatter = new DateFormat("jm");

  var endtimeformatter = new DateFormat("jm");

  @override
  void initState() {
    super.initState();
    // Initialize the current user location on first map build
    _getUserLocation();
    
  }

  Widget build(BuildContext context) {
    
    // We create the streambuilder here to allow us to constantly listen in to changes to the Games
    // database. The materialApp is wrapped inside the streambuilder so we can update data that is used
    // in the materialApp.
    return new StreamBuilder(
        // Only fetch current games
        stream: Firestore.instance
            .collection(dbCol)
            .document(widget.gameid)
            // Order in ascending order so we can track which games are older.
            // This is so we can correctly layer the map using zindex on the
            // google map
            .snapshots(),
        builder: (context, snapshot) {
          // Any time the snapshot has new data, update the markerlsit
          if (snapshot.hasData) {
            AsyncSnapshot<DocumentSnapshot> snap = snapshot;
            currentgame = new Game(
                id: widget.gameid,
                userid: "Pull user ID here",
                address: "Pull address here",
                endtime: snap.data['endtime'],
                location: snap.data['location'],
                note: snap.data['note'],
                playersneeded: snap.data['playersneeded'],
                private: snap.data['private'],
                sport: snap.data['sport'],
                starttime: snap.data['starttime']);


                _getUserLocation();

                   markerlist.add( new Marker(
              markerId: MarkerId(widget.gameid),
              position: LatLng(currentgame.location.latitude,
                  currentgame.location.longitude),
            ));
            
           
          } else {
            // Show this loading map screen when we are loading in the database data
            return MaterialApp(
              home: Container(
                child: Center(
                  child: Text(
                    'loading map..',
                    style: TextStyle(
                        fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
                  ),
                ),
              ),
            );
          }
          return MaterialApp(
              title: "Game Detail Page",
              // If the initial position is null, return a container saying that we are loading the map.
              home: Scaffold(
                appBar: AppBar(
                  title: Text("Game Details"),
                  leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
                    Navigator.pop(context);
                  } )
                ),
                body: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.pin_drop, color: Colors.blue),
                        title: Text(currentgame.address),
                      ),
                      ListTile(
                          leading:
                              Icon(Icons.calendar_today, color: Colors.blue),
                          title: Text(gamedateformatter.format(
                              currentgame.starttime.toDate().toLocal()))),

                      Row(children: <Widget>[
                        Expanded(
                          child: ListTile(
                            leading:
                                Icon(Icons.directions_run, color: Colors.blue),
                            title: Text(currentgame.sport),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: Icon(Icons.people, color: Colors.blue),
                            title: Text(currentgame.playersneeded.toString()),
                          ),
                        ),
                      ]),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              leading: Icon(Icons.timer, color: Colors.blue),
                              title: Text(starttimeformatter.format(
                                  currentgame.starttime.toDate().toLocal())),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              leading:
                                  Icon(Icons.timer_off, color: Colors.blue),
                              title: Text(endtimeformatter.format(
                                  currentgame.endtime.toDate().toLocal())),
                            ),
                          ),
                        ],
                      ),

                      ListTile(
                        leading: Icon(Icons.person, color: Colors.blue),
                        title: Text(currentgame.userid),
                      ),
                      ListTile(
                        leading: Icon(Icons.event_note, color: Colors.blue),
                        title: Text(currentgame.note),
                      ),

                      _center == null
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
                          : Expanded(
                              flex: 2,
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: _center,
                                  zoom: 15,
                                ),
                                markers: markerlist,
                              )),

                      //    home: _userlocation == null
                      // ? Container(
                      //     child: Center(
                      //       child: Text(
                      //         'loading map..',
                      //         style: TextStyle(
                      //             fontFamily: 'Avenir-Medium',
                      //             color: Colors.grey[400]),
                      //       ),
                      //     ),
                      //   )
                      // // Once the initial position is not null, create the google map.
                      // : GoogleMap(
                      //     onMapCreated: _onMapCreated,
                      //     initialCameraPosition: CameraPosition(
                      //       target: _userlocation,
                      //       zoom: 11.0,
                      //     ),
                      //     markers: markerlist,
                      //   ),

                      RaisedButton(
                          onPressed: () {},
                          textColor: Colors.white,
                          color: Colors.blue,
                          child: Text("Join Game"))
                    ],
                  ),
                ),
              ));
        });
  }
}
