import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart';

// This class will store the database reference we are using.
class Database {
  final firestoreDb = Firestore.instance;
  var games;
  var usergames;
  var user;
  var profile;
  var activegames;

// Default constructor
  Database() {
    games = [];
    user = [];
    profile = [];
    activegames=[];
  }

  void addgame(var game) {
    firestoreDb.collection(dbCol).add(game);
  }

  //creates a new user profile in database after user signups
  void adduser(String user){
    firestoreDb.collection('User').document(user).setData({'games':[]});
  }

  //updates the user profile with newly joined game
  void updateuser(String _userid, String games) {
     firestoreDb.collection('User').document(_userid).updateData({
        "games": FieldValue.arrayUnion([games])
    });    
  }

    //removes the game from user collection
   void leaveuser(String _userid, String games){
     firestoreDb.collection('User').document(_userid).updateData({
        "games": FieldValue.arrayRemove([games])
    }); 
   }

    //checks if the user has joined the particular game on the games details page or not
   bool gamestatus(String _userid, String gameID){
      var data = firestoreDb.collection('User').document(_userid);
      data.get().then((dataSnapshot){
        if (dataSnapshot.exists){   
            return ((dataSnapshot.data['games']).contains(gameID));
        }
      });

      return false;
     
   }

 //Returns all the games information in array format
 List<dynamic> getGames(){
    firestoreDb.collection(dbCol).snapshots().listen((data)=> data.documents.forEach((doc)=>games.add(doc.data)));
    return games;
  }

  Stream<dynamic> getGamesbyUser(String userId){
    firestoreDb.collection(dbCol).where('userId', isEqualTo: userId).snapshots().listen((data)=> data.documents.forEach((doc)=>games.add(doc.data)));
    return usergames;
  }
}
