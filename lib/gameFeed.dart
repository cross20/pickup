import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pickup_app/globals.dart';
import 'games.dart';
import 'game.dart';

class GameFeed extends StatefulWidget {
  _GameFeedState createState() => _GameFeedState();
}

// Formats the content that will appear in the list item by item. The content is formatted
// using a container object.
// The main body for the game feed. Uses a column to manage multiple widgets in the body.
class _GameFeedState extends State<GameFeed> {
  /// Set to `true` to show games in the feed, set to `false` to show games in the map.
  List<Game> filteredGames = new List<Game>();
  Games gamesOverlord = new Games();

  @override
  initState() {
    super.initState();
  }

  // The main body for the game feed. Uses a column to manage multiple widgets in the body.
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: filter.baseball,
        builder: (BuildContext context, bool value, Widget child) {
          return StreamBuilder(
              stream: Firestore.instance.collection(dbCol).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    alignment: Alignment.topCenter,
                    child: Container(
                        padding: EdgeInsets.all(16),
                        child: const CircularProgressIndicator()),
                  );
                } else if (snapshot.hasData) {
                  return FutureBuilder(
                      future: gamesOverlord
                          .getFilteredGames(snapshot.data.documents),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          filteredGames = snapshot.data;

                          if (filteredGames.length > 0) {
                            return ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: filteredGames.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return gamesOverlord.getGameCard(
                                    context: context,
                                    game: filteredGames[index],
                                  );
                                });
                          } else {
                            return Text('No games');
                          }
                        } else {
                          return Column(
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.all(16),
                                  child: const CircularProgressIndicator()),
                            ],
                          );
                        }
                      });
                } else {
                  return Text('Nothing here.');
                }
              });
        });
  }
}
