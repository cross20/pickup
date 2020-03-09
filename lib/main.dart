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

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Basic PickUp Game Creator Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String dropdownsport = "Basketball"; ///initial value of sport
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

  Future<Null> selectstartTime(BuildContext context) async {
    pickedStart = await showTimePicker(
      context: context,
      initialTime: _timeStart,);

    setState(() {
      _timeStart = pickedStart;
      startGameTime = DateTime(startGameTime.year, startGameTime.month, startGameTime.day, pickedStart.hour, pickedStart.minute, 00);
    });
    }

  Future<Null> selectendTime(BuildContext context) async {
    pickedEnd = await showTimePicker(
      context: context,
      initialTime: _timeEnd,);

    setState(() {
      _timeEnd = pickedEnd;
      endGameTime = DateTime(endGameTime.year, endGameTime.month, endGameTime.day, pickedEnd.hour, pickedEnd.minute, 00);
    });
    }

    ////this function is called when submit button is hit, this is where I figured the update to database would occur
  void _updateData() {
    ///to pass in the timestamp of both startGameTime and endGameTime,
      var startTime = startGameTime.millisecondsSinceEpoch / 1000;
      var endTime = endGameTime.millisecondsSinceEpoch / 1000;

    ///set bool for public/private match
      bool priv = false;
      if(dropdownpub == "Public")
          priv = false;
      else
          priv = true;

    // void creategame() {
    // Game game = new Game(
    //     endtime: endTime,
    //     location: GeoPoint(47.0, 23.2), ///eventually will be addr after Google API integration
    //     note: msg,
    //     playersneeded: _currentNumPlay,
    //     private: priv,
    //     sport: dropdownsport,
    //     starttime: startTime);
    // instance.addgame(game.toMap());


    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // A game will be pushed to the database everytime the + button is clicked
      creategame();
    });
  }

  // Function to create a new game and add to the firestore database.
  void creategame() {
    Game game = new Game(
        endtime: Timestamp.now(),
        location: GeoPoint(47.0, 23.2),
        note: "Ball needed",
        playersneeded: 5,
        private: true,
        sport: "Football",
        starttime: Timestamp.now());
    instance.addgame(game.toMap());
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

///enter address -------------------------------------------------------------
            Row(
              children: <Widget>[
                Container(
                    child: Text('Address:', style: TextStyle(fontSize: 20),),
                    constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 100.0, minHeight: 50.0, minWidth: 50.0),
                    alignment: Alignment.center,),
                Container(
                    child: TextField(decoration: InputDecoration( hintText: 'Enter Address Here'), controller: myControllerAddr,),
                    constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 300.0, minHeight: 50.0, minWidth: 50.0),),],
            ),

///time and date row ------------------------------------------------------------
            Row(children: <Widget>[
              Container( //Time/Date text
                child: Text('Time/Date:', style: TextStyle(fontSize: 20)),
                constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 100.0, minHeight: 50.0, minWidth: 50.0),
                alignment: Alignment.bottomCenter,),
              Container(
                child: FlatButton( ///date button
                    onPressed: () {
                            DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                              maxTime: DateTime(2020, 12, 31), onChanged: (date) {
                            print('change $date');
                            gameDate = date;
                            startGameTime = DateTime(gameDate.year, gameDate.month, gameDate.day, startGameTime.hour, startGameTime.minute, 00);
                            endGameTime = DateTime(gameDate.year, gameDate.month, gameDate.day, endGameTime.hour, endGameTime.minute, 00);
                          }, onConfirm: (date) {
                            print('confirm $date');
                          }, currentTime: gameDate, locale: LocaleType.en);
                      },
                          child: Text(
                              'date',
                           style: TextStyle(color: Colors.blue),
                    )),
                  constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 100.0, minHeight: 50.0, minWidth: 50.0),
                  alignment: Alignment.center,),
                Container(
                  child: FlatButton( ////start time button
                    onPressed: () {
                      selectstartTime(context);
                    },
                        child: Text(
                              'start time',
                           style: TextStyle(color: Colors.blue),
                    )),
                  constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 100.0, minHeight: 50.0, minWidth: 50.0),
                  alignment: Alignment.center,),
                Container(
                  child: FlatButton( ////end time button
                    onPressed: () {
                      selectendTime(context);
                    },
                        child: Text(
                              'end time',
                           style: TextStyle(color: Colors.blue),
                    )),
                  constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 100.0, minHeight: 50.0, minWidth: 50.0),
                  alignment: Alignment.center,)

            ],),

// select sport ------------------------------------------------------------------------
            Row( //sport row
              children: <Widget>[
                Container(
                  child: Text( 'Sport:',style: TextStyle(fontSize: 20), ),
                  constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 100.0, minHeight: 50.0, minWidth: 50.0),
                  alignment: Alignment.center,),
                Container(
                  child: DropdownButton<String>(
                            value: dropdownsport,
                            iconSize: 20,
                            onChanged: (String newValue){
                            setState(() {
                               dropdownsport = newValue;
                            });
                            },
                            items: <String> ['Basketball', 'Soccer', 'Football', 'Baseball']
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value),);
                             }).toList(),
                      ),
                  alignment: Alignment.centerRight,
                 )
              ]),

// private or public match ----------------------------------------------------------
            Row( //private or public match row
              children: <Widget>[
                Container(
                  child: Text("Private or Public match?", style: TextStyle(fontSize: 20)),
                  constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 200.0, minHeight: 50.0, minWidth: 50.0),
                  alignment: Alignment.center,
                  ),
                Container(
                  alignment: Alignment.center,
                  child: DropdownButton<String>(
                      value: dropdownpub,
                      iconSize: 20,
                      onChanged: (String newValue){
                       setState(() {
                          dropdownpub = newValue;
                       });
              },
              items: <String> ['Private', 'Public']
                .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value),);
                }).toList(),
                ),)
              ],
            ),

///# of players ---------------------------------------------------------------------------------
            Row(children: <Widget>[
              Container(alignment: Alignment.centerLeft,
                child: Text('# of players: ', style: TextStyle(fontSize: 20),),
                constraints: BoxConstraints(maxHeight: 50.0, maxWidth: 200.0, minHeight: 50.0, minWidth: 50.0),),
              Container(alignment: Alignment.center,
                child: new NumberPicker.integer(
                  initialValue: _currentNumPlay,
                  minValue: 3,
                  maxValue: 25,
                  onChanged:(newValue) =>
                    setState(() => _currentNumPlay = newValue))
                )
            ],),


 ///any addition commments
            TextField(decoration: InputDecoration( hintText: 'Anything else to note:'), controller: myControlMsg,),


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
