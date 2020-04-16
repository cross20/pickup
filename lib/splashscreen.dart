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
import 'authentication.dart';
import 'dart:async';

// Create a global variable that can help us get information about
// the users device. 
MediaQueryData globaldevicestats;

class SplashScreenPage extends StatefulWidget {
  SplashScreenPage({Key key, this.title, this.auth, this.userId, this.logoutCallback}): super(key:key);

  final String title;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  

  @override
  State<StatefulWidget> createState() => new _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>{
  final firestore_db = Firestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool userlogged = false;
  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }


  getUser(){
    if (widget.auth.getCurrentUser()!=null)
      userlogged = true;
  }

  @override
  Widget build(BuildContext context) {
    getUser();
    // Initialize the local variable when the user hits the splash screen
    // so we can get screen size
    globaldevicestats = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),
      actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
          ),
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
               child: Text("To map page")),
             
                //signup button
              RaisedButton(onPressed: (){
                   Navigator.pushNamed(context, '/signup');
              },
              child: Text("To signup page")),

              RaisedButton(onPressed: (){
              Navigator.pushNamed(context, '/gameFeed');
            },
              child: Text("To game feed"),
            ),

      ],) ));
              
  }
}