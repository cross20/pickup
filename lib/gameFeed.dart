import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:pickup_app/appUI.dart';
import 'package:pickup_app/globals.dart';
import 'package:rxdart/rxdart.dart';
import 'filterPage.dart';
import 'findGameMap.dart';
import 'globals.dart' as globals;

Firestore _firestore = Firestore.instance;
Geoflutterfire geo;
Stream<List<DocumentSnapshot>> stream;

class GameFeed extends StatefulWidget {
  GameFeedState createState() => GameFeedState();
}

// Formats the content that will appear in the list item by item. The content is formatted
// using a container object.
// The main body for the game feed. Uses a column to manage multiple widgets in the body.
class GameFeedState extends State<GameFeed> {
  /// Set to `true` to show games in the feed, set to `false` to show games in the map.
  bool _showGameFeed = true;

  var radius = BehaviorSubject<double>.seeded(1.0);

  @override
  initState() {
    super.initState();
    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 48.0, longitude: 117.0);
    stream = radius.switchMap((rad) {
      print('rad is $rad');
      var collectionReference = _firestore.collection(dbCol);
      return geo
          .collection(collectionRef: collectionReference)
          .within(center: center, radius: 100, field: 'point', strictMode: true);
    });
  }

  /// Updates the value of [_showGameFeed] using [setState].
  void shouldShowGameFeed(bool showFeed) {
    setState(() {
      this._showGameFeed = showFeed;
    });
  }

  /// Formats each individual game to appear in the listView.builder.
  Widget createGameCard(BuildContext context, DocumentSnapshot document) {
    DateTime startTime = (document['starttime'] as Timestamp).toDate();
    DateTime endTime = (document['endtime'] as Timestamp).toDate();

    return new Card(
      child: ListTile(
        title: RichText(
          text: TextSpan(
            text: '${document['sport']} Game',
            style:
                DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
          ),
        ),
        subtitle: RichText(
            text: TextSpan(
          text: _prettyDate(startTime, endTime),
          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1),
        )),
        /* trailing: ,*/ // TODO: Replace text with icon.
      ),
    );
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
                child: /*StreamBuilder(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.hasError) {
                  return new Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data.length > 0) {
                  //print('data ${snapshot.data.toString()}. length ${snapshot.data.length}');
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) =>
                        createGameCard(context, snapshot.data[index]),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )*/

                StreamBuilder(
              stream: gamesSnapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Loading...');
                }
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) =>
                        createGameCard(
                            context, snapshot.data.documents[index]));
              },
            )
                );
          });
    } else {
      //Display map
      return Expanded(
          child: SizedBox(
              height: 200.0,
              child:
                  new FindGameMap())); //Column(children: <Widget>[Text("This is for the map")],);
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

/*Stream<List<DocumentSnapshot>> gameSnapshots() {
  return geo
      .collection(collectionRef: Firestore.instance.collection(dbCol))
      .within(center: center, radius: 100.0, field: 'point');
}*/

/// Retrieves the games from the database based on the filter values selected. Also, filters out
/// games which have ended.
Stream<QuerySnapshot> gamesSnapshots() {
  CollectionReference col = Firestore.instance.collection(dbCol);

  //Query q = col.where('playersneeded', isGreaterThan: 0);

  Geoflutterfire geo = Geoflutterfire();
  GeoFireCollectionRef geoRef = geo.collection(collectionRef: col);
  GeoFirePoint center = GeoFirePoint(47.0, 117.0);

  Stream<List<DocumentSnapshot>> stream =
      geoRef.within(center: center, radius: 100, field: 'location');

  Stream<QuerySnapshot> qs = geoRef.snapshot();

  //return qs;

  List<String> includedSports = new List<String>();

  if (filter.baseball.value) {
    includedSports.add('Baseball');
  }

  if (filter.basketball.value) {
    includedSports.add('Basketball');
  }

  if (filter.football.value) {
    includedSports.add('Football');
  }

  if (filter.soccer.value) {
    includedSports.add('Soccer');
  }

  if (includedSports.isEmpty) {
    //return q.limit(0).snapshots();
  }

  Query q = col.where('sport', whereIn: includedSports.toList());

  return q.snapshots();
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
