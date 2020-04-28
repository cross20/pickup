import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authentication.dart';
import 'gameFeed.dart';
import 'createGame.dart';
import 'myGamesUI.dart';

class SplashScreenPage extends StatefulWidget {
  SplashScreenPage(
      {Key key, this.title, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  final firestore_db = Firestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool userlogged = false;

  String _userId = "";

  List _pageOptions;

  int _selectedTab = 0;

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  getUser() {
    if (widget.auth.getCurrentUser() != null) userlogged = true;
  }

//changes the state of userid to the current user id in the session
  getUserId() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getUser();
    getUserId();
    _pageOptions = List();

    //pages are added to the list after this widget is built
    _pageOptions.add(GameFeed());
    _pageOptions.add(CreateGamePage(userId: _userId));
    _pageOptions.add(MyGamesPage(userId: _userId));

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: (_pageOptions[
                _selectedTab] //displays the page based on navbar selection
            ),

        //navbar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (int index) {
            setState(() {
              _selectedTab =
                  index; // identifies which button on navbar is clicked
              return _selectedTab;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text("Home")),
            BottomNavigationBarItem(icon: Icon(Icons.add), title: Text("Add")),
            BottomNavigationBarItem(
                icon: Icon(Icons.photo), title: Text("Profile")),
          ],
        ) // botNavBAr() Defined in appUI.dart file

        );
  }
}
