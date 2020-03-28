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
import 'createGame.dart';
import 'splashscreen.dart';
import 'map.dart';
import 'gameFeed.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreenPage(title: 'Splash Screen'),
      routes: <String, WidgetBuilder> {
        '/createGame': (BuildContext context) => CreateGamePage(title: "Create Game Page"),
        '/map':(BuildContext context) => MapPage(title: "This is the map"),
        '/gameFeed':(BuildContext context) => GameFeed(title: "Games"),
      }
    );
  }
}

