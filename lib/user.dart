import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:geoflutterfire/geoflutterfire.dart';

// Data Model Class to store game information and allow for both serialization and deserialization
// of firebase data.
class User {  
  final String userid;
 final List<String> games;
    

  // Default Constructor
  User ({this.userid,this.games});

 // Function that allows for deserializaiton of Game Objects from the 
  // firestore database. When we will be retreiving game information from the
  // database, they will be returned to us in Map form. We need this
  // fromMap function to easily convert the firestore data to be accessed
  // within our class. Inspired by the link below in the section: From a Map or JSON
  // https://fireship.io/lessons/advanced-flutter-firebase/
  
   factory User.fromMap(Map data) {
    data = data ?? {};
    return User(
      userid: data['userid'] ?? '',
     games: List.from (data['game']) ?? '',
      
    );
  }

  /// Function that allows for deserializaiton of Game Objects from the
  /// firestore database. When we will be retreiving game information from the
  /// database, they will be returned to us in firestore form form. We need this
  /// fromfirestore function to easily convert the firestore data to be accessed
  /// within our class. Inspired by the link below in the section: From a firestore document.
  /// We can either use fromFirestore or fromMap to deserialize our data. I believe we should
  /// use from fromFirestore so that we can assign each game the doc ID key that is generated in the firestore
  /// DB. If we do not use this strategy I am not sure how we will access the key.
  /// https://fireship.io/lessons/advanced-flutter-firebase/
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return User(
      userid: data['userid'] ?? '',
     games: List.from (data['games']) ?? ''
      
    );
  }

  /// Function that maps our game object to the proper format
  /// in order to be added to the database.
  /// Inspired by the link below
  /// https://flutter.institute/firebase-firestore/
  Map<String, dynamic> toMap() => {
        'userid': this.userid,
        'games': this.games
      };
}
