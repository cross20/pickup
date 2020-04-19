import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:pickup_app/appUI.dart';
import 'filterPage.dart';
import 'findGameMap.dart';
import 'filter.dart';

class GameFeed extends StatefulWidget {
  GameFeedState createState() => GameFeedState();
}

// Formats the content that will appear in the list item by item. The content is formatted
// using a container object.
// The main body for the game feed. Uses a column to manage multiple widgets in the body.
class GameFeedState extends State<GameFeed> {
  /// Set to `true` to show games in the feed, set to `false` to show games in the map.
  bool _showGameFeed = true;

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

  /// Formats each individual game to appear in the listView.builder.
  Widget listBody(BuildContext context, DocumentSnapshot document) {
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
      return Expanded(
          child: StreamBuilder(
        stream: gamesSnapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading...');
          }
          return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) =>
                  listBody(context, snapshot.data.documents[index]));
        },
      ));
    } else {
      //Display map
      return Expanded(
          child: SizedBox(
              height: 200.0,
              child:
                  new FindGameMap())); //Column(children: <Widget>[Text("This is for the map")],);
    }
  }

  ///This is to determine the new Route that must be selected
  /// to navigate to depending on which bottom nav button is selected
  ///  newRoute() is defined in appUI.dart file
  void _onBotNavTap(int index) {
    newRoute(index, context);
  }

  // The main body for the game feed. Uses a column to manage multiple widgets in the body.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text('Games')),
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
                  }, // TODO: Determine which filter options are needed and to display them.
                  child: Icon(Icons.filter_list),
                )
              ],
            ),
          ),
          feedOrMap(),
        ],
      ),
      bottomNavigationBar: botNavBar(
          0, _onBotNavTap, context), // botNavBAr() Defined in appUI.dart file
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

Stream<QuerySnapshot> gamesSnapshots() {
  CollectionReference col = Firestore.instance.collection('Games');

  Geoflutterfire geo = Geoflutterfire();
  GeoFirePoint center = GeoFirePoint(47.0, 117.0);
  geo
      .collection(collectionRef: col)
      .within(center: center, radius: 100, field: 'position');

      

  /*bool includeSports = false;
  for (bool shouldInclude in includeSport.values) {
    if (shouldInclude) {
      includeSports = true;
    }
  }

  if (!includeSports) {
    return col
        .where('sport', isEqualTo: 'None')
        .where('endtime', isGreaterThan: new DateTime.now())
        .snapshots();
  }

  if (includeSport['baseball']) {
    col.where('sport', isEqualTo: 'Baseball');
  }

  if (includeSport['basketball']) {
    col.where('sport', isEqualTo: 'Basketball');
  }

  if (includeSport['football']) {
    col.where('sport', isEqualTo: 'Football');
  }

  if (includeSport['soccer']) {
    col.where('sport', isEqualTo: 'Soccer');
  }*/

  return col.where('endtime', isGreaterThan: new DateTime.now()).snapshots();
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
