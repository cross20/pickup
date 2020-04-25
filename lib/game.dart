import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Data Model Class to store game information and allow for both serialization and deserialization
// of firebase data.
class Game {
  final String id;
  String userid;
  String address;
  Timestamp endtime;
  GeoPoint location;
  String note;
  int playersneeded;
  bool private;
  String sport;
  Timestamp starttime;

  toString() {
    return this.endtime.toString() +
        ', ' +
        this.location.toString() +
        ', ' +
        this.note +
        ', ' +
        this.playersneeded.toString() +
        ', ' +
        this.private.toString() +
        ', ' +
        this.sport +
        ', ' +
        this.starttime.toString();
  }

  // Default Constructor
  Game(
      { this.id,
      this.userid,
      this.address,
      this.endtime,
      this.location,
      this.note,
      this.playersneeded,
      this.private,
      this.sport,
      this.starttime});
  
  // Function that allows for deserializaiton of Game Objects from the 
  // firestore database. When we will be retreiving game information from the
  // database, they will be returned to us in Map form. We need this
  // fromMap function to easily convert the firestore data to be accessed
  // within our class. Inspired by the link below in the section: From a Map or JSON
  // https://fireship.io/lessons/advanced-flutter-firebase/
  factory Game.fromMap(Map data) {
    data = data ?? {};
    return Game(
      endtime: data['endtime'] ?? '',
      location: data['location'] ?? '',
      note: data['note'] ?? '',
      playersneeded: data['playersneeded'] ?? 0,
      private: data['private'] ?? false,
      sport: data['sport'] ?? '',
      starttime: data['starttime'] ?? '',
    );
  }
  
  // Function that allows for deserializaiton of Game Objects from the 
  // firestore database. When we will be retreiving game information from the
  // database, they will be returned to us in firestore form form. We need this
  // fromfirestore function to easily convert the firestore data to be accessed
  // within our class. Inspired by the link below in the section: From a firestore document.
  // We can either use fromFirestore or fromMap to deserialize our data. I believe we should 
  // use from fromFirestore so that we can assign each game the doc ID key that is generated in the firestore
  // DB. If we do not use this strategy I am not sure how we will access the key.
  // https://fireship.io/lessons/advanced-flutter-firebase/
  factory Game.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return Game(
      id: doc.documentID,
      endtime: data['endtime'] ?? '',
      location: data['location'] ?? '',
      note: data['note'] ?? '',
      playersneeded: data['playersneeded'] ?? 0,
      private: data['private'] ?? false,
      sport: data['sport'] ?? '',
      starttime: data['starttime'] ?? '',
    );
  }


  // Function that maps our game object to the proper format
  // in order to be added to the database.
  // Inspired by the link below
  // https://flutter.institute/firebase-firestore/
  Map<String, dynamic> toMap() => {
        'endtime': this.endtime,
        'location': this.location,
        'note': this.note,
        'playersneeded': this.playersneeded,
        'private': this.private,
        'sport': this.sport,
        'starttime': this.starttime,
      };
}
