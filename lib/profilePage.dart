import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key key, this.userId:''}) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Text('This will contain the profile.'),
    );
  }
}