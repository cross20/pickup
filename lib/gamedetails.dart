import 'package:flutter/material.dart';
import 'appUI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game.dart';
import 'package:intl/intl.dart';

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
  Game currentgame;
  @override
  Widget build(BuildContext context) {
    // We create the streambuilder here to allow us to constantly listen in to changes to the Games
    // database. The materialApp is wrapped inside the streambuilder so we can update data that is used
    // in the materialApp.
    return new StreamBuilder(
        // Only fetch current games
        stream: Firestore.instance
            .collection('Games')
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
                userid: snap.data['userid'].toString(),
                address: snap.data['address'],
                endtime: snap.data['endtime'],
                location: snap.data['location'],
                note: snap.data['note'],
                playersneeded: snap.data['playersneeded'],
                private: snap.data['private'],
                sport: snap.data['sport'],
                starttime: snap.data['starttime']);
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
                ),
                body: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.pin_drop),
                        title: Text("1234 N Main St"),
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text("User123"),
                      ),
                      ListTile(
                        leading: Icon(Icons.directions_run),
                        title: Text(currentgame.sport),
                      ),
                      ListTile(
                        leading: Icon(Icons.people),
                        title: Text(currentgame.playersneeded.toString()),
                      ),
                      ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text("Apr 26, 2020")),
                      ListTile(
                        leading: Icon(Icons.timer),
                        title: Text("5:30 PM"),
                      ),
                      ListTile(
                        leading: Icon(Icons.timer_off),
                        title: Text("6:30 PM"),
                      ),
                      ListTile(
                        leading: Icon(Icons.event_note),
                        title: Text("Bring a ball"),
                      ),
                      RaisedButton(onPressed: () {}, child: Text("Join Game"))
                    ],
                  ),
                ),
              ));
        });
  }
}
