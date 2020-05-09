import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pickup_app/appUI.dart';
import 'package:pickup_app/gamedetails.dart';
import 'package:pickup_app/globals.dart';
import 'package:intl/intl.dart';
import 'filterPage.dart';
import 'findGameMap.dart';
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
              stream: gamesSnapshots(),
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

  /// This is to determine the new Route that must be selected
  /// to navigate to depending on which bottom nav button is selected
  /// newRoute() is defined in appUI.dart file
  void _onBotNavTap(int index) {
    newRoute(index, context);
  }

  // The main body for the game feed. Uses a column to manage multiple widgets in the body.
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(automaticallyImplyLeading: false),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            child: Row(
              // Filter by location (current or specified).
              children: <Widget>[
                FlatButton(
                  onPressed:
                      null, // TODO: Display a search bar and keyboard to search for a location.
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

/// Retrieves the games from the database.
Stream<QuerySnapshot> gamesSnapshots() {
  CollectionReference col = Firestore.instance.collection(dbCol);

  return col.snapshots();
}

/// Formats DateTime objects for games. Returns a string which describes a game's current status:
/// finished, in progress, or starting soon.
String _prettyDate(DateTime startTime, DateTime endTime) {
  Duration zero = Duration(seconds: 0);
  Duration thirtyMinutes = Duration(minutes: 30);
  Duration oneHour = Duration(hours: 1);
  Duration oneDay = Duration(days: 1);

  Duration timeUntilStart = startTime.difference(DateTime.now());
  Duration timeUntilEnd = endTime.difference(DateTime.now());

  // If the game hasn't started.
  if (timeUntilStart > zero) {
    if (timeUntilStart < oneHour) {
      Duration minutes = Duration(minutes: timeUntilStart.inMinutes);
      return 'Starting in ${minutes.inMinutes} minutes.';
    } else if (timeUntilStart < oneDay) {
      Duration hours = Duration(hours: timeUntilStart.inHours);
      Duration minutes = timeUntilStart - hours;
      return 'Starting in ${hours.inHours} hours and ${minutes.inMinutes} minutes.';
    } else {
      return 'Starting in ${timeUntilStart.inDays} days.';
    }
  }

  // If the game hasn't finished.
  else if (timeUntilEnd > zero) {
    if (timeUntilEnd <= thirtyMinutes) {
      return 'Ending soon';
    } else if (timeUntilEnd < oneHour) {
      Duration minutes = Duration(minutes: timeUntilEnd.inMinutes);
      return 'Ending in ${minutes.inMinutes} minutes.';
    } else {
      Duration hours = Duration(hours: timeUntilEnd.inHours);
      Duration minutes = timeUntilEnd - hours;
      return 'Ending in ${hours.inHours} hours and ${minutes.inMinutes} minutes.';
    }
  }

  // If the game has finished.
  else {
    return 'Game has finished.';
  }
}
