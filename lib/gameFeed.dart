import 'package:flutter/material.dart';
import 'database.dart';
import 'game.dart';

// Global Database linking to firestore
Database instance = new Database();

class GameFeed extends StatefulWidget {
  GameFeed({Key key, this.title}) : super(key: key);

  final String title;

  _GameFeedState createState() => _GameFeedState();
}

class _GameFeedState extends State<GameFeed> {
  // Formats the content that will appear in the list item by item. The content is formatted
  // using a container object.
  Widget listBody(BuildContext context, int index) {
    return new Card(
      child: ListTile(
        subtitle: Text('${index}'),
        title: Text(getGame(index).sport),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: instance.getgame().length,
          itemBuilder: (BuildContext context, int index) => listBody(context, index)
          )
      ),
    );
  }
}

// Converts a game from the database to a Game object. Uses the index
// for the instance object to access the game from the database.
Game getGame(int index) {
  return Game.fromMap(instance.getgame().elementAt(index));
}