import 'package:pickup_app/findGameMap.dart';
import 'package:pickup_app/gamesPage.dart';
import 'package:pickup_app/myGamesPage.dart';
import 'package:flutter/material.dart';
import 'createGame.dart';
import 'gameDetailsPage.dart';
import 'signup_login.dart';
import 'authroot.dart';
import 'authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(auth: new Auth()),
      routes: <String, WidgetBuilder> {
        '/createGame': (BuildContext context) => CreateGamePage(title: "Create Game Page"),
        '/map':(BuildContext context) => FindGameMap(title: "This is the map"),
        //'/login':(BuildContext context) => LoginPage(),
        '/signup':(BuildContext context) => SignupLoginPage(),
        '/gameFeed':(BuildContext context) => GamesPage(),
        '/myGames':(BuildContext context) => MyGamesPage(),
        '/gamedetails' : (BuildContext context) => GameDetailsPage("Game ID Value"),
      }
    );
  }
}
