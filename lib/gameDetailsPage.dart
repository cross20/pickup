import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'globals.dart';
import 'globals.dart' as global;
import 'database.dart';


Database instance = new Database();

class GameDetailsPage extends StatefulWidget {
  // This variable will store the gameid
  // for the specific game we are displaying the details for.
  // This game id will be used to query for vital game information.
  final String gameid;


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
    setState(() {
      _center = LatLng(
          query.data['location'].latitude, query.data['location'].longitude);
    });
  }

  Game currentgame;
  GoogleMapController _controller;
  bool joinedGameState;

  static LatLng _center;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }
  //checks if the user has joined the game or not
    bool usergamestatus(String userid, String games)
    {
      return instance.gamestatus(userid,games);
    }
    
  //user joins the game and user collection is updated
  void updatetheuser(String userid, String games) 
      {
        instance.updateuser(userid,games);
      }

    //user leaves the game and user collection is updated
   void leavetheuser(String userid, String games) 
      {
        instance.leaveuser(userid,games);
      }

  Set<Marker> markerlist = new Set();

  var gamedateformatter = new DateFormat('yMMMMEEEEd');

  var starttimeformatter = new DateFormat("jm");

  var endtimeformatter = new DateFormat("jm");

  @override
  void initState() {
    super.initState();
    // Initialize the current user location on first map build
    _center = null;
    _getUserLocation();
    joinedGameState = instance.gamestatus(global.userId, widget.gameid);
  }

  Widget build(BuildContext context) {

    return new StreamBuilder(
        // Get the current game
        stream: Firestore.instance
            .collection(dbCol)
            .document(widget.gameid)
            .snapshots(),
        builder: (context, snapshot) {
          // Any time the snapshot has new data, update the game info
          if (snapshot.hasData) {
            AsyncSnapshot<DocumentSnapshot> snap = snapshot;
            currentgame = new Game(
                id: widget.gameid,
                userid: snap.data['userId'],
                address: snap.data['address'],
                endtime: snap.data['endtime'],
                location: snap.data['location'],
                note: snap.data['note'],
                playersneeded: snap.data['playersneeded'],
                private: snap.data['private'],
                sport: snap.data['sport'],
                starttime: snap.data['starttime']);

            markerlist.add(new Marker(
              markerId: MarkerId(widget.gameid),
              position: LatLng(currentgame.location.latitude,
                  currentgame.location.longitude),
            ));
          } else {
            // Show this loading map screen when we are loading in the database data
            return MaterialApp(
              debugShowCheckedModeBanner: false,
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
            debugShowCheckedModeBanner: false,
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
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: true,
                                zoomGesturesEnabled: true,
                                mapToolbarEnabled: true,
                                initialCameraPosition: CameraPosition(
                                  target: _center,
                                  zoom: 15,
                                ),
                                markers: markerlist,
                              )),

                      new RaisedButton(
                        onPressed: () {
                          if(joinedGameState == false) {
                            updatetheuser(global.userId, widget.gameid);
                            setState(() {
                              joinedGameState = !joinedGameState;
                            });
                          }
                          else{
                            leavetheuser(global.userId, widget.gameid);
                            setState(() {
                              joinedGameState = !joinedGameState;
                            });
                          }
                        },
                          textColor: Colors.white,
<<<<<<< HEAD
                          color: Colors.blue,
                          child: Text("Join Game")),

                      Padding(
                        padding: EdgeInsets.all(16.0),
                      ),
                    
=======
                          color: joinedGameState ? Colors.red: Colors.blue,
                          child: joinedGameState ? Text("Leave Game"): Text("Join Game"),
                  )

>>>>>>> joinGamesFunctionality
                    ],
                  ),
                ),
              ));
        });
  }
}
