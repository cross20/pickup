
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pickup_app/createGame.dart';
import 'package:pickup_app/database.dart';
import 'package:pickup_app/gameDetailsPage.dart';
import 'game.dart';
import 'globals.dart';
import 'games.dart';

Database instance = new Database();

class MyGamesPage extends StatefulWidget {
  MyGamesPage({Key key, this.userId: ""}) : super(key: key);
  final userId;

  _MyGamesPageState createState() => _MyGamesPageState(userId: this.userId);
}

class _MyGamesPageState extends State<MyGamesPage> {
  String userId;
  Games gamesOverlord = new Games();


  _MyGamesPageState({this.userId});

  Stream<QuerySnapshot> createdGamesSnapshots() {
    CollectionReference col = Firestore.instance.collection(dbCol);
    return col.where('userId', isEqualTo: this.userId).snapshots();
  }

  Stream<QuerySnapshot> joinedGamesSnapshots() {
    CollectionReference col = Firestore.instance.collection(dbCol);
    return col.where('userId', isEqualTo: this.userId).snapshots();
  }



  Widget createdGamesList() {
    return Expanded(
        child: StreamBuilder(
      stream: createdGamesSnapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            alignment: Alignment.topCenter,
            child: Container(
                padding: EdgeInsets.all(16),
                child: const CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                Game g = Game.fromFirestore(snapshot.data.documents[index]);
                return gamesOverlord.getGameCard(
                    context: context, game: g, canDelete: true);
                //return listBody(context, snapshot.data.documents[index]);
              });
        } else {
          return Text('No games');
        }
      },
    ));
  }

  Widget joinedGamesList() {
    return Expanded(
        child: StreamBuilder(
          stream: joinedGamesSnapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                alignment: Alignment.topCenter,
                child: Container(
                    padding: EdgeInsets.all(16),
                    child: const CircularProgressIndicator()),
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    Game g = Game.fromFirestore(snapshot.data.documents[index]);
                    return gamesOverlord.getGameCard(
                        context: context, game: g, canDelete: false);
                    //return listBody(context, snapshot.data.documents[index]);
                  });
            } else {
              return Text('No games');
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: Text('Your Games')),
=======
>>>>>>> joinGamesFunctionality
      body: Column(
        children: <Widget>[
          AppBar(
            title: Text("Created Games"),
            centerTitle: true,
          ),
          Container(
            child: createdGamesList(),
          ),
          AppBar(
            title: Text("Joined Games"),
            centerTitle: true,
          ),
          Container(
            child: joinedGamesList(),
          )
        ],
      ),
    );
  }
}
