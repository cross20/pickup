import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pickup_app/createGame.dart';
import 'package:pickup_app/gameDetailsPage.dart';
import 'game.dart';
import 'globals.dart';
import 'games.dart';

class MyGamesPage extends StatefulWidget {
  MyGamesPage({Key key, this.userId: ""}) : super(key: key);
  final userId;

  _MyGamesPageState createState() => _MyGamesPageState(userId: this.userId);
}

class _MyGamesPageState extends State<MyGamesPage> {
  String userId;
  //global ref to all games
  CollectionReference col = Firestore.instance.collection(dbCol);
  Games gamesOverlord = new Games();

  _MyGamesPageState({this.userId});

  Stream<QuerySnapshot> gamesSnapshots() {
    //function to display desired games (can be changed)
    return col.where('userId', isEqualTo: this.userId).snapshots();
  }

  Future<String> createAlertDialog(
      BuildContext context, DocumentSnapshot document) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Are you sure you want to delete this game?"),
            actions: <Widget>[
              MaterialButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              MaterialButton(
                child: Text("Yes"),
                onPressed: () {
                  Firestore.instance
                      .collection(dbCol)
                      .document(document.documentID)
                      .delete();
                  Navigator.of(context).pop(document['sport']);
                },
              )
            ],
          );
        });
  }

  Widget createdGamesList() {
    Query q = col.where('userId', isEqualTo: this.userId);
    if (q.snapshots().isEmpty != true) {
      return Expanded(
          child: StreamBuilder(
        stream: gamesSnapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  // TODO: Implement new stype of cards!
                  Game g = Game.fromFirestore(snapshot.data.documents[index]);
                  //return gamesOverlord.getGameCard(context: context, game: g, useEditMode: true);
                  return listBody(context, snapshot.data.documents[index]);
                });
          } else {
            return Text('No games');
          }
        },
      ));
    } else {
      return (Expanded(
        child: Center(
            child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('You haven\'t created a game yet!'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text('Create Game'),
                onPressed: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CreateGamePage()))
                },
              ),
            )
          ],
        )),
      ));
    }
  }

  Widget joinedGamesList() {
    CollectionReference col = Firestore.instance.collection(dbCol);
    Query q = col.where('userId', isEqualTo: this.userId);
    bool test = true;
    //TODO: mess with empty query to display 'no games' widget
    if (test != true) {
      return Expanded(
          child: StreamBuilder(
        stream: gamesSnapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) =>
                  listBody(context, snapshot.data.documents[index]));
        },
      ));
    } else {
      return (Expanded(
        child: Center(
            child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('You haven\'t joined any games yet!'),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Text('Navigate to the game feed to find games near you!'))
          ],
        )),
      ));
    }
  }

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
        trailing: new IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            createAlertDialog(context, document).then((game) {
              SnackBar confirmDelete =
                  SnackBar(content: Text("Your $game game has been deleted."));
              Scaffold.of(context).showSnackBar(confirmDelete);
            });
          },
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  // Pass the game ID to the page so we can access data for the specific game
                  builder: (context) => GameDetailsPage(document.documentID)));
        },
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Games')),
      body: Column(
        children: <Widget>[
          Container(
            child: createdGamesList(),
          ),
          //Container(
          //child: joinedGamesList(),
          //)
        ],
      ),
    );
  }
}
