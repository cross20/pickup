import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'game.dart';

// This class will store the database reference we are using.
class Database {
  final firestore_db = Firestore.instance;

// Default constructor
  Database();

  void addgame(var game) {
    firestore_db.collection('Games').add(game);
  }

  //Returns all the games information in array format
 var games=[] ;
 List<dynamic> getGames(){
    firestore_db.collection('Games').snapshots().listen((data)=> data.documents.forEach((doc)=>games.add(doc.data)));
    return games;
  }
}
