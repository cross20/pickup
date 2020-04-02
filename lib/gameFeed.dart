import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameFeed extends StatefulWidget {
  GameFeed({Key key, this.title}) : super(key: key);

  final String title;

  _GameFeedState createState() => _GameFeedState();
}

class _GameFeedState extends State<GameFeed> {
  /// Formats each individual game to appear in the listView.builder.
  Widget listBody(BuildContext context, DocumentSnapshot document) {
    DateTime startTime = (document['starttime'] as Timestamp).toDate();
    Duration timeUntilStart = startTime.difference(DateTime.now());

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
          text: timeUntilStart > Duration(seconds: 0) ? 'Starting in ${timeUntilStart.inDays} days' : 'Started',
          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1),
        )),
        /* trailing: ,*/ // TODO: Replace text with icon.
      ),
    );
  }

  // The main body for the game feed. Uses a column to manage multiple widgets in the body.
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // Choose how to view games. Either in list or map form. Select filter options and
          // search location.
          actions: <Widget>[
            FlatButton(
              onPressed:
                  null, // TODO: Display a search bar and keyboard to search for a location.
              child: Text('Location'), // TODO: Replace text with icon.
            ),
            Expanded(
              // TODO: Replace button bar with tab bar.
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                buttonMinWidth: 80.0,
                children: <Widget>[
                  RaisedButton(
                    onPressed: null, // TODO: Load the list view.
                    child: Text(
                      'List',
                    ),
                  ),
                  RaisedButton(
                    onPressed: null, // TODO: Load the map view.
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
              child: Text('Filter'), // TODO: Replace text with icon.
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            // Display in a list.
            Expanded(
                child: StreamBuilder(
              //stream: Firestore.instance.collection('Games').snapshots(),
              stream: Firestore.instance
                  .collection("Games")
                  .orderBy('starttime', descending: false)
                  .snapshots(),
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
            )),
          ],
        ));
  }
}

/// Used to manage the various filter options for organizing Game objects as they appear in the
/// game feed and on the map.
class FilterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Back'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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

/// Formats DateTime objects for games. Returns a string which describes a game's current status:
/// finished, in progress, or starting soon.
/*String _prettyDate(DateTime startTime, DateTime endTime) {
  Duration thirtyMinutes = Duration(minutes: 30);
  Duration gameDuration = endTime.difference(startTime);

  if(endTime.isBefore(DateTime.now())) {
    return 'Game is finished';
  } else if(gameDuration) {
    return 'Game is finishing soon';
  }

  return 'error calculating time';
}
*/