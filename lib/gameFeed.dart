import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pickup_app/gamedetails.dart';
import 'package:pickup_app/globals.dart';
import 'package:intl/intl.dart';
import 'filterPage.dart';
import 'findGameMap.dart';
import 'locationPage.dart';
import 'game.dart';

class GameFeed extends StatefulWidget {
  GameFeedState createState() => GameFeedState();
}

// Formats the content that will appear in the list item by item. The content is formatted
// using a container object.
// The main body for the game feed. Uses a column to manage multiple widgets in the body.
class GameFeedState extends State<GameFeed> {
  /// Set to `true` to show games in the feed, set to `false` to show games in the map.
  bool _showGameFeed = true;
  List<Game> filteredGames = new List<Game>();

  @override
  initState() {
    super.initState();
  }

  /// Updates the value of [_showGameFeed] using [setState].
  void shouldShowGameFeed(bool showFeed) {
    setState(() {
      this._showGameFeed = showFeed;
    });
  }

  /// Function to determine with Widget to show on game feed route. If list is set to true (i.e,
  /// the List Button was last selected, then show list, else show map)
  Widget feedOrMap() {
    if (_showGameFeed == true) {
      //Display list
      return ValueListenableBuilder(
          valueListenable: filter.baseball,
          builder: (BuildContext context, bool value, Widget child) {
            return Expanded(
                child: StreamBuilder(
              stream: Firestore.instance.collection(dbCol).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                filteredGames = getFilteredGames(snapshot.data.documents);

                if (filteredGames.length > 0) {
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredGames.length,
                      itemBuilder: (BuildContext context, int index) =>
                          getGameCard(context, filteredGames[index]));
                } else {
                  return Text('No games');
                }
              },
            ));
          });
    } else {
      //Display map
      return Expanded(child: SizedBox(height: 200.0, child: new FindGameMap()));
    }
  }

  // The main body for the game feed. Uses a column to manage multiple widgets in the body.
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            child: Row(
              // Filter by location (current or specified).
              children: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).push(_createRoute(LocationPage())),
                  child: Icon(Icons.edit_location),
                ),
                // Choose how to view games. Either in list or map form.
                Expanded(
                  child: ButtonBar(
                    alignment: MainAxisAlignment.center,
                    buttonMinWidth: 80.0,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () => {shouldShowGameFeed(true)},
                        child: Text(
                          'List',
                        ),
                      ),
                      RaisedButton(
                        onPressed: () => {shouldShowGameFeed(false)},
                        child: Text(
                          'Map',
                        ),
                      ),
                    ],
                  ),
                ),
                // Filter by game type (e.g. Basketball, Football, etc.), time, etc.
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(_createRoute(FilterPage()));
                  },
                  child: Icon(Icons.filter_list),
                )
              ],
            ),
          ),
          feedOrMap(),
        ],
      ),
    );
  }
}

/// Custom route transition that animates the page from the bottom of the screen. This function
/// returns a PageRouteBuilder.
///
/// The [page] parameter must not be null. It should be a valid constructor for a route.
Route _createRoute(page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondartAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var tween = Tween(begin: begin, end: end);
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

/// Takes games for a list of [DocumentSnapshot] objects, converts them to game objects,
/// and then removes games that the filter indicates should not be included in the results.
List<Game> getFilteredGames(List<DocumentSnapshot> list) {
  List<Game> games = new List<Game>();

  // Convert every game from the database to a Game object.
  for (DocumentSnapshot doc in list) {
    games.add(Game.fromFirestore(doc));
  }

  if (!filter.baseball.value) {
    games.removeWhere((Game g) => g.sport == "Baseball");
  }

  if (!filter.basketball.value) {
    games.removeWhere((Game g) => g.sport == "Basketball");
  }

  if (!filter.football.value) {
    games.removeWhere((Game g) => g.sport == "Football");
  }

  if (!filter.soccer.value) {
    games.removeWhere((Game g) => g.sport == "Soccer");
  }

  // Remove games that have already started.
  games.removeWhere((Game g) => g.starttime.toDate().isBefore(DateTime.now()));

  GeoPoint point = GeoPoint(47.7682, 117.4273);

  games.sort((Game g1, Game g2) {
    int comp = g1.starttime.compareTo(g2.starttime);
    if (comp != 0) return comp;
    return distanceBetweenPoints(g1.location, point)
        .compareTo(distanceBetweenPoints(g2.location, point));
  });

  return games;
}

/// Calculates the distance between two [GeoPoint] objects using the standard distance
/// formula.
double distanceBetweenPoints(GeoPoint a, GeoPoint b) {
  // TODO: Create a better distance caluclator. This barely accurte and doesn't return a useful number.
  // A more useful number would be one of miles or kilometers.
  return sqrt((b.latitude - a.latitude) * (b.latitude - a.latitude) +
      (b.longitude - a.longitude) * (b.longitude - a.longitude));
}

/// Formats each individual game to appear in the listView.builder.
Widget getGameCard(BuildContext context, Game g) {
  DateFormat date = new DateFormat('MMM d');
  DateFormat time = (MediaQuery.of(context).alwaysUse24HourFormat)
      ? new DateFormat('HH:MM')
      : new DateFormat('hh:mm a');
  // TODO: Figure out how to compute distance from one point to another.

  return new Card(
    child: ListTile(
      title: Text('${g.sport} Game'),
      subtitle: Text(
          '${date.format(g.starttime.toDate())} at ${time.format(g.starttime.toDate())},\n' +
              '0.1 miles away,\n' +
              '${g.playersneeded} players needed.'),
      trailing: Icon(Icons.chevron_right),
      isThreeLine: true,
      contentPadding: EdgeInsets.fromLTRB(14, 0, 14, 10),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GameDetailsPage(g.id)));
      },
    ),
  );
}
