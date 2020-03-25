///this is the "home" screen
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

class SplashScreenPage extends StatefulWidget {
  SplashScreenPage({Key key, this.title}): super(key:key);

  final String title;

  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),),
      body: Center(child: Column(children: <Widget>[
            Text("This is the splashscreen"),
            RaisedButton(
              onPressed: (){
                   Navigator.pushNamed(context, '/createGame');
              },
              child: Text("To create game page"),
            ),
            RaisedButton(onPressed: (){
                   Navigator.pushNamed(context, '/map');
              },
              child: Text("To map page"),
            ),
            RaisedButton(onPressed: (){
              Navigator.pushNamed(context, '/gameFeed');
            },
              child: Text("To game feed"),
            ),
          ],
        ) 
      )
    );
  }
}