import 'package:flutter/material.dart';
import 'globals.dart' as globals;

/// Holds key-pair values for each [sport] in the database.
///
/// Used to track local changes to filter values without updating the global values.
/// The global value should be updated based on the values in this [Map] if it is
/// appropriate to update the global values.
Map sport = {
  'baseball': globals.filter.baseball,
  'basketball': globals.filter.basketball,
  'football': globals.filter.football,
  'soccer': globals.filter.soccer,
};

class FilterPage extends StatefulWidget {
  FilterPageState createState() => FilterPageState();
}

class FilterPageState extends State<FilterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sport['baseball'] = globals.filter.baseball;
              sport['basketball'] = globals.filter.basketball;
              sport['football'] = globals.filter.football;
              sport['soccer'] = globals.filter.soccer;
              Navigator.pop(context);
            },
            child: Icon(
              Icons.close,
            ),
          ),
          Spacer(),
          FlatButton(
              onPressed: () {
                // Update the global filter values to reflect the local changes.
                globals.filter.include(sport['baseball'], sport['basketball'],
                    sport['football'], sport['soccer']);
                Navigator.pop(context);
              },
              child: Icon(
                Icons.done,
              )),
        ],
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          CheckboxListTile(
            title: const Text('Baseball'),
            value: sport['baseball'],
            onChanged: (bool value) {
              setState(() {
                sport['baseball'] = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Basketball'),
            value: sport['basketball'],
            onChanged: (bool value) {
              setState(() {
                sport['basketball'] = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Football'),
            value: sport['football'],
            onChanged: (bool value) {
              setState(() {
                sport['football'] = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Soccer'),
            value: sport['soccer'],
            onChanged: (bool value) {
              setState(() {
                sport['soccer'] = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
