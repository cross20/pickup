//this file includes all function related for authentication process

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'database.dart';
import 'user.dart';

Database instance = new Database();


//constructor for BaseAuth
abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();


  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

 
}

void createuser(String _userid, List <String>_games) {
      User user = new User(userid: _userid, games:_games);
      //instance.adduser(user.toMap());  
      instance.adduser(_userid);
  }

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

    


  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
         FirebaseUser user = result.user;
         String userid = user.uid.toString();
         createuser(userid, []);
        
        return user.uid;
    
   
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

 

  
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    print ("user.isEmailVerified");
    return user.isEmailVerified;
    
  }

  
}