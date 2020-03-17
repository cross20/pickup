/////This is the game creation page

import 'dart:convert';
import 'package:geocoder/services/base.dart';

import 'game.dart';
import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter_google_places/flutter_google_places.dart';/// google places package
import 'package:geocoder/geocoder.dart'; // geocoder from address to geopoint

// Global Database linking to firestore
Database instance = new Database();

// this class is for initializing this page
class CreateGamePage extends StatefulWidget {
  CreateGamePage({Key key, this.title}) : super(key: key);

  final String title;

  _CreateGamePageState createState() => _CreateGamePageState();
}

// this class is for setting the state of the page, it is stateful so widgets within this class can change.
// This class starts off by defining all the data types and methods I need to properly display and save all game data needed.
// Then the updateData() method is next, which is called when user hits submit, this is where the Game object is created
// and sent to the database.
// Finally is the build method, where all the Widgets are that are needed for this UI
class _CreateGamePageState extends State<CreateGamePage> {
  // init value of dropdownmenu
  String dropdownsport = "Basketball";

  ///init value of sport
  String dropdownpub = "Public"; //initial value of priv or pub match

  ///controllers for listening to address, msg, sport, pub/priv input
  final myControllerAddr = TextEditingController(); //for the entered address
  final myControlMsg = TextEditingController(); // for the entered Message
  final myControlSport = TextEditingController(); // for sport selection
  final myControlpub = TextEditingController(); // for pub/priv match selection

  //init value of user inputted address
  String addr = " ";

  //init value of user inputted message
  String msg = " ";

  //init # of players
  int _currentNumPlay = 3;

  ///init values from Date and times of game
  var gameDate = DateTime.now();
  var startGameTime = DateTime.now();
  var endGameTime = DateTime.now();

  /// https://www.youtube.com/watch?v=iX3vCtcHwPE timePicker from that video
  TimeOfDay _timeStart = TimeOfDay.now();
  TimeOfDay pickedStart;

  /// this method is for the creation of the timePicker to select the start time of the game
  Future<Null> selectstartTime(BuildContext context) async {
    pickedStart = await showTimePicker(
      context: context,
      initialTime: _timeStart,
    );

    setState(() {
      _timeStart = pickedStart;
      startGameTime = DateTime(startGameTime.year, startGameTime.month,
          startGameTime.day, pickedStart.hour, pickedStart.minute, 00);
    });
  }

  /// this method is for the timePicker to select the ending time of the game
  TimeOfDay _timeEnd = TimeOfDay.now();
  TimeOfDay pickedEnd;
  Future<Null> selectendTime(BuildContext context) async {
    pickedEnd = await showTimePicker(
      context: context,
      initialTime: _timeEnd,
    );

    setState(() {
      _timeEnd = pickedEnd;
      endGameTime = DateTime(endGameTime.year, endGameTime.month,
          endGameTime.day, pickedEnd.hour, pickedEnd.minute, 00);
    });
  }

  /// this function is called when submit button is hit, this is where values are updated and casted to proper data type
  /// to be sent to the server
  void _updateData() {
    ///to pass in the timestamp of both startGameTime and endGameTime,
    Timestamp _starttime = Timestamp.fromDate(startGameTime);
    Timestamp _endtime = Timestamp.fromDate(endGameTime);

    ///set bool for public/private match
    bool priv = false;
    if (dropdownpub == "Public")
      priv = false;
    else
      priv = true;

    setState(() {
      ///addr = myControlAddr
      msg = myControlMsg.text;

      // A game will be pushed to the database everytime the "submit" button is clicked
      creategame(_endtime, GeoPoint(47.0, 23.2), msg, _currentNumPlay, priv,
          dropdownsport, _starttime);
    });
  }

  // Function to create a new game and add to the firestore database.
  void creategame(Timestamp _endtime, GeoPoint _location, String _note,
      int _playersneeded, bool _private, String _sport, Timestamp _starttime) {
    Game game = new Game(
      endtime: _endtime,
      location: _location,
      note: _note,
      playersneeded: _playersneeded,
      private: _private,
      sport: _sport,
      starttime: _starttime,
    );
    instance.addgame(game.toMap());
  }

  ///all the defined UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ///address row
            Row(
              children: <Widget>[
                Container(
                  child: Text(
                    'Address:',
                    style: TextStyle(fontSize: 20),
                  ),
                  constraints: BoxConstraints(
                      maxHeight: 50.0,
                      maxWidth: 100.0,
                      minHeight: 50.0,
                      minWidth: 50.0),
                  alignment: Alignment.center,
                ),
                Container(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Enter Address Here'),
                    controller: myControllerAddr,
                  ),
                  constraints: BoxConstraints(
                      maxHeight: 50.0,
                      maxWidth: 300.0,
                      minHeight: 50.0,
                      minWidth: 50.0),
                ),
              ],
            ),

            ///time and date row
            Row(
              children: <Widget>[
                Container(
                  //Time/Date text
                  child: Text('Time/Date:', style: TextStyle(fontSize: 20)),
                  constraints: BoxConstraints(
                      maxHeight: 50.0,
                      maxWidth: 100.0,
                      minHeight: 50.0,
                      minWidth: 50.0),
                  alignment: Alignment.bottomCenter,
                ),
                Container(
                  child: FlatButton(
                      ///date button
                      onPressed: () {
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            minTime: DateTime(DateTime.now().year,
                                DateTime.now().month, DateTime.now().day),
                            maxTime: DateTime(2020, 12, 31), onChanged: (date) {
                          print('change $date');
                          gameDate = date;
                          startGameTime = DateTime(
                              gameDate.year,
                              gameDate.month,
                              gameDate.day,
                              startGameTime.hour,
                              startGameTime.minute,
                              00);
                          endGameTime = DateTime(
                              gameDate.year,
                              gameDate.month,
                              gameDate.day,
                              endGameTime.hour,
                              endGameTime.minute,
                              00);
                        }, onConfirm: (date) {
                          print('confirm $date');
                        }, currentTime: gameDate, locale: LocaleType.en);
                      },
                      child: Text(
                        'date',
                        style: TextStyle(color: Colors.blue),
                      )),
                  constraints: BoxConstraints(
                      maxHeight: 50.0,
                      maxWidth: 100.0,
                      minHeight: 50.0,
                      minWidth: 50.0),
                  alignment: Alignment.center,
                ),
                Container(
                  child: FlatButton(
                      ////start time button
                      onPressed: () {
                        selectstartTime(context);
                      },
                      child: Text(
                        'start time',
                        style: TextStyle(color: Colors.blue),
                      )),
                  constraints: BoxConstraints(
                      maxHeight: 50.0,
                      maxWidth: 100.0,
                      minHeight: 50.0,
                      minWidth: 50.0),
                  alignment: Alignment.center,
                ),
                Container(
                  child: FlatButton(
                      ////end time button
                      onPressed: () {
                        selectendTime(context);
                      },
                      child: Text(
                        'end time',
                        style: TextStyle(color: Colors.blue),
                      )),
                  constraints: BoxConstraints(
                      maxHeight: 50.0,
                      maxWidth: 100.0,
                      minHeight: 50.0,
                      minWidth: 50.0),
                  alignment: Alignment.center,
                )
              ],
            ),

            /// sport row
            Row(children: <Widget>[
              Container(
                child: Text(
                  'Sport:',
                  style: TextStyle(fontSize: 20),
                ),
                constraints: BoxConstraints(
                    maxHeight: 50.0,
                    maxWidth: 100.0,
                    minHeight: 50.0,
                    minWidth: 50.0),
                alignment: Alignment.center,
              ),
              Container(
                child: DropdownButton<String>(
                  value: dropdownsport,
                  iconSize: 20,
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownsport = newValue;
                    });
                  },
                  items: <String>[
                    'Basketball',
                    'Soccer',
                    'Football',
                    'Baseball'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                alignment: Alignment.centerRight,
              )
            ]),
            // private or public match row
            Row(
              children: <Widget>[
                Container(
                  child: Text("Private or Public match?",
                      style: TextStyle(fontSize: 20)),
                  constraints: BoxConstraints(
                      maxHeight: 50.0,
                      maxWidth: 200.0,
                      minHeight: 50.0,
                      minWidth: 50.0),
                  alignment: Alignment.center,
                ),
                Container(
                  alignment: Alignment.center,
                  child: DropdownButton<String>(
                    value: dropdownpub,
                    iconSize: 20,
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownpub = newValue;
                      });
                    },
                    items: <String>['Private', 'Public']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),

            ///# of players row
            Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '# of players: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  constraints: BoxConstraints(
                      maxHeight: 50.0,
                      maxWidth: 200.0,
                      minHeight: 50.0,
                      minWidth: 50.0),
                ),
                Container(
                    alignment: Alignment.center,
                    child: new NumberPicker.integer(
                        initialValue: _currentNumPlay,
                        minValue: 3,
                        maxValue: 25,
                        onChanged: (newValue) =>
                            setState(() => _currentNumPlay = newValue)))
              ],
            ),

            ///add any addition messages or notes that players should know row
            TextField(
              decoration: InputDecoration(hintText: 'Anything else to note:'),
              controller: myControlMsg,
            ),

            /// these lines of Text widgets here are simply here to make sure all data is being stored correctly
            /// this will not go into the final app, I (Casey) just made these to help me see data was being stored properly
            Text('addr: $addr'),
            Text('msg: $msg'),
            Text('sport: $dropdownsport'),
            Text('pub/priv: $dropdownpub'),
            Text('num of players: $_currentNumPlay'),
            Text('Start time: $_timeStart'),
            Text('End time: $endGameTime'),
            Text('Full start time date/time: ${startGameTime})'),
            Text('${startGameTime.toString()}'),
          ],
        ),
      ),
      // the submit button
      floatingActionButton: FloatingActionButton(
        onPressed: _updateData,
        tooltip: 'Increment',
        child: Text('Submit'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
