import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'game.dart';

// This class will store the database reference we are using.
class Database {
  final firestoreDb = Firestore.instance;
  var games;

// Default constructor
  Database() {
    games = [];
  }

  void addgame(var game) {
    firestoreDb.collection('Games').add(game);
  }

  // Returns all the games information in array format.
  List<dynamic> getGames(){
    firestoreDb.collection('Games').snapshots().listen((data)=> data.documents.forEach((doc)=>games.add(doc.data)));
    return games;
  }
}
