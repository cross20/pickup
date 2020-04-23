
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'game.dart';

class MyGamesPage extends StatefulWidget {
  @override
  _MyGamesPageState createState() => _MyGamesPageState();
}

class _MyGamesPageState extends State<MyGamesPage> {
  List<Game> myGames;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Games')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: myGames.length,
                itemBuilder: (BuildContext context, position) {
                  return ListTile(
                    
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}
