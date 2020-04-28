//this files helps to determine which page/content to show based on authentication status
//this page is loaded first and depending on authentication status relevant page is shown to users

import 'package:flutter/material.dart';
import 'signup_login.dart';
import 'authentication.dart';
import 'splashscreen.dart';

//type of authentication at any given time
enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  //initialize the authstate by looking at the current user
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;//logged in if userid is not null
      });
    });
  }

//this function is trigerred after login form is submitted
  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

//this function is trigerred when logout button is called
  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  //builds and returns pages based on user authentication status
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED: //auth is not known
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN://display signup/login page if not logged in
        return new SignupLoginPage(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN://displays splashscreepage(homepage) if logged in
        if (_userId.length > 0 && _userId != null) {
          
          return new SplashScreenPage(
            title: "PickUp",
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}