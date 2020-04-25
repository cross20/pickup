import 'package:flutter/material.dart';
import 'appUI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game.dart';

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
           currentgame = new Game(id: widget.gameid, 
           userid: snap.data['userid'].toString(),
           address: snap.data['address'],
           endtime: snap.data['endtime'],
           location: snap.data['location'],
           note: snap.data['note'],
           playersneeded: snap.data['playersneeded'],
           private: snap.data['private'],
           sport: snap.data['sport'],
           starttime: snap.data['starttime'] );
           
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
              home: Text(currentgame.sport),
          );
        });
  }
}