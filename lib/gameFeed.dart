import 'dart:convert';
import 'game.dart';
import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

Database instance = new Database();

class GameFeedPage extends StatefulWidget {
  GameFeedPage({Key key, this.title}): super(key:key);

  final String title;

  _GameFeedPageState createState() => _GameFeedPageState();
}

class _GameFeedPageState extends State<GameFeedPage> {
  @override
  Widget build(BuildContext context) {
    final games = <Widget>[];
    final localGames = instance.getGames();
    for(var i = 0; i < instance.getGames().length; i++) {
      Game g = localGames.elementAt(i);
      games.add(new Card(child: ListTile(title: Text('temp'))));
    }

    // Scaffold for games feed.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new ListView(
        children: games,
        addAutomaticKeepAlives: false,
      ),
    );
  }
  
}