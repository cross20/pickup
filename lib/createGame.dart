/////This is the game creation page

import 'dart:convert';
import 'game.dart';
import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

// Global Database linking to firestore
Database instance = new Database();

class CreateGamePage extends StatefulWidget {
  CreateGamePage({Key key, this.title}) : super(key: key);

  final String title;

  _CreateGamePageState createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  String dropdownsport = "Basketball";

  ///initial value of sport
  String dropdownpub = "Public"; //initial value of priv or pub match

  final myControllerAddr = TextEditingController(); //for the entered address
  final myControlMsg = TextEditingController(); // for the entered Message
  final myControlSport = TextEditingController(); // for sport selection
  final myControlpub = TextEditingController(); // for pub/priv match selection

  //address in string form
  String addr = " ";

  //Notes in string form
  String msg = " ";

  ///# of players
  int _currentNumPlay = 3;

  var gameDate = DateTime.now();
  var startGameTime = DateTime.now();
  var endGameTime = DateTime.now();

  final format = DateFormat("yyyy-MM-dd HH:mm"); //for the DateTimePicker

  ///https://www.youtube.com/watch?v=iX3vCtcHwPE timePicker from that video
  TimeOfDay _timeStart = TimeOfDay.now();
  TimeOfDay pickedStart;

  TimeOfDay _timeEnd = TimeOfDay.now();
  TimeOfDay pickedEnd;

  ///this method and the following method are to show the time picker
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

  ////this function is called when submit button is hit, this is where I figured the update to database would occur
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

      // A game will be pushed to the database everytime the + button is clicked
      ///addr = myControlAddr
      msg = myControlMsg.text;
      creategame(_endtime, GeoPoint(47.0, 23.2), msg, _currentNumPlay, priv, dropdownsport, _starttime);
    });

  }

  // Function to create a new game and add to the firestore database.
  void creategame(Timestamp _endtime, GeoPoint _location, String _note,
      int _playersneeded, bool _private, String _sport, Timestamp _starttime) {
    Game game = new Game(
        endtime:  _endtime,
        location: _location,
        note: _note,
        playersneeded: _playersneeded,
        private: _private,
        sport: _sport,
        starttime: _starttime,
    );
    instance.addgame(game.toMap());
  }

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
            ///enter address -------------------------------------------------------------
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

            ///time and date row ------------------------------------------------------------
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

// select sport ------------------------------------------------------------------------
            Row(//sport row
                children: <Widget>[
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

// private or public match ----------------------------------------------------------
            Row(
              //private or public match row
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

            ///# of players ---------------------------------------------------------------------------------
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

            ///any addition commments
            TextField(
              decoration: InputDecoration(hintText: 'Anything else to note:'),
              controller: myControlMsg,
            ),

////text to show the entered information
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

// the submit button ------------------------------------------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: _updateData,
        tooltip: 'Increment',
        child: Text('Submit'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
