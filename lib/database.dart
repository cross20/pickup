import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart';

// This class will store the database reference we are using.
class Database {
  final firestoreDb = Firestore.instance;
  var games;
  var usergames;

// Default constructor
  Database() {
    games = [];
  }

  void addgame(var game) {
    firestoreDb.collection(dbCol).add(game);
  }

 //Returns all the games information in array format
 List<dynamic> getGames(){
    firestoreDb.collection(dbCol).snapshots().listen((data)=> data.documents.forEach((doc)=>games.add(doc.data)));
    return games;
  }

  List<dynamic> getGamesbyUser(){
    firestoreDb.collection(dbCol).where('userId', isEqualTo:"MeqU5s6zeUbSDQeWOOncpl4cdyn1").snapshots().listen((data)=> data.documents.forEach((doc)=>games.add(doc.data)));
    return usergames;
  }
}
