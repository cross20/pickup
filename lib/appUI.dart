///This file is to put Widgets and functions that will be called repeatedly throughout the app
/// defining them in one place and calling on them over multiple Widgets allows for more efficiency 

import 'package:flutter/material.dart';
import 'package:pickup_app/myGamesUI.dart';
import 'createGame.dart';
import 'gameFeed.dart';


/// This is where the bot nav bar is defined for the app. 
BottomNavigationBar botNavBar (int current, Function onTap, BuildContext context) =>
  BottomNavigationBar(type: BottomNavigationBarType.shifting,
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.black,),
            title: Text('Home', style: TextStyle(color: Colors.black),),),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: Colors.black),
            title: Text("Profile", style: TextStyle(color: Colors.black))),
          BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.black,),
            title: Text("New Game", style: TextStyle(color: Colors.black))),
          BottomNavigationBarItem(icon: Icon(Icons.settings, color: Colors.black,),
            title: Text("Settings", style: TextStyle(color: Colors.black)))
        ],
        currentIndex: current,
        onTap: onTap,);


/// This function is for when an bottom nav bar item is selected, this should be called
/// in the switch case, it simply looks at the index, then calls the next page to be uploaded
void newRoute(int index, BuildContext context) {
  switch (index) {
    case 0:
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => GameFeedState(
                    title: "Home Feed",
                  )));
      break;
    case 1:
       Navigator.push(
           context,
           PageRouteBuilder(
               pageBuilder: (context, animation1, animation2) => MyGamesPage(

                   )));
      break;
    case 2:
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => CreateGamePage(
                    title: "Create Game",
                  )));
      break;
    case 3:
      // Navigator.push(
      //     context,
      //     PageRouteBuilder(
      //         pageBuilder: (context, animation1, animation2) => SettingsPage(
      //               title: "Settings",
      //             )));
      break;
  }
}
