import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pickup_app/appUI.dart';
import 'findGameMap.dart';

/// Stores a boolean value for each [sport] that determines wheather or not a game should
/// be loaded from the database.
Map includeSport = {
  'baseball': true,
  'basketball': true,
  'football': true,
  'soccer': true
};

class GameFeedState extends StatefulWidget {
  GameFeedState({Key key }) : super(key: key);

  

  _GameFeedState createState() => _GameFeedState();
}

  // Formats the content that will appear in the list item by item. The content is formatted
  // using a container object.
  // The main body for the game feed. Uses a column to manage multiple widgets in the body.
class _GameFeedState extends State<GameFeedState> {
  bool _list = true;

  @override
  initState(){
    super.initState();
    _list = true;
  }

  void setList(bool list){
    setState(() {
      _list = list;
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


  ///Function to determine with Widget to show on game feed route. If _list is set to true (i.e,
  /// the List Button was last selected, then show list, else show map)
  Widget listOrMap (){
    if (_list == true){
      //Display list
      return 
            Expanded(
              child: StreamBuilder(
                stream: gamesSnapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return const Text('Loading...');
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) => listBody(context, snapshot.data.documents[index])
                  );
                },
              )
            );
    }
    else {
      //Display map
      return Expanded(child: SizedBox(height:200.0, child: new FindGameMap()));//Column(children: <Widget>[Text("This is for the map")],);
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
     
      body: //Center(
        //child:
        Column(
          children: <Widget>[
            Container(
              color: Colors.blue,
              child: Row(
                // Filter by location (current or specified).
                children: <Widget>[
                  FlatButton(
                    onPressed: null, // TODO: Display a search bar and keyboard to search for a location.
                    child: Text('Location'),
                  ),
                  // Choose how to view games. Either in list or map form.
                  Expanded(
                    child: ButtonBar(
                      alignment: MainAxisAlignment.center,
                      buttonMinWidth: 80.0,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () => {
                            //set list bool to true
                            setList(true)
                          }, // TODO: Load the list view.
                          child: Text('List',),
                        ),
                        RaisedButton(
                          onPressed: () => {
                            setList(false)  
                          }, // TODO: Load the map view.
                          child: Text('Map',),
                        ),
                      ],
                    ),
                  ),
                  // Filter by game type (e.g. Basketball, Football, etc.), time, etc.
                  FlatButton(
                    onPressed: () {Navigator.of(context).push(_createRoute(FilterPage()));}, // TODO: Determine which filter options are needed and to display them.
                    child: Text('Filter'),
                  )
                ],
              ),
            ),
            listOrMap(),
          ],
        )
      // botNavBAr() Defined in appUI.dart file
    );
  }}
  
class GameFeed extends StatefulWidget {
  GameFeed({Key key}) : super(key: key);

  @override
  _GameFeed createState() => _GameFeed();
}

class _GameFeed extends State<GameFeed> {
  @override
  Widget build(BuildContext context) {
    return Text('temp');
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
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.close,
            ),
          ),
          Spacer(),
          FlatButton(
              onPressed: () {
                // TODO: Figure out how to refresh the games that appear in the listView.builder.
                Navigator.pop(context);
              },
              child: Icon(
                Icons.done,
              )),
        ],
      ),
      body: StatefulFilterPage(),
    );
  }
}

class StatefulFilterPage extends StatefulWidget {
  StatefulFilterPage({Key key}) : super(key: key);

  @override
  _StatefulFilterPage createState() => _StatefulFilterPage();
}

class _StatefulFilterPage extends State<StatefulFilterPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        CheckboxListTile(
          title: const Text('Basketball'),
          value: includeSport['basketball'],
          onChanged: (bool value) {
            setState(() {
              includeSport['basketball'] = value;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Football'),
          value: includeSport['football'],
          onChanged: (bool value) {
            setState(() {
              includeSport['football'] = value;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Soccer'),
          value: includeSport['soccer'],
          onChanged: (bool value) {
            setState(() {
              includeSport['soccer'] = value;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Baseball'),
          value: includeSport['baseball'],
          onChanged: (bool value) {
            setState(() {
              includeSport['baseball'] = value;
            });
          },
        ),
        Text('Date picker goes here') // TODO: Implement dateTimePicker here.
      ],
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
  //return Firestore.instance.collection('Games').where('endtime', isGreaterThan: new DateTime.now()).snapshots();

  CollectionReference col = Firestore.instance.collection('Games');

  bool includeSports = false;
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
  }

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
