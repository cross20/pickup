import 'game.dart';
import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:dio/dio.dart';
import 'appUI.dart';

// google places packages
import "package:google_maps_webservice/places.dart"; // for the GoogleMapPlaces
import 'package:uuid/uuid.dart'; //for session token

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
  // This is the Google Maps Place API
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: "AIzaSyBQTQwCWEASIKWsXPXyOx70kAenVJgrSA0");
  String googlePlacesAPI = "AIzaSyBQTQwCWEASIKWsXPXyOx70kAenVJgrSA0";
  var address;
  //for the session ID token
  var uuid = new Uuid();
  String _sessionToken;
  List<String> _placesList = [];
  GeoFirePoint _location;

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

    //need to reset session token after submit button is selected
    _sessionToken = null;

    setState(() {
      addr = myControllerAddr.text;
      msg = myControlMsg.text;

      // A game will be pushed to the database everytime the "submit" button is clicked
      creategame(_endtime, _location, msg, _currentNumPlay, priv, dropdownsport,
          _starttime);
    });
  }

  //When this page is first created, the _onSearchChanged is added to the
  // Address controller so that _onSearch can be called every time
  // user changes the input of address
  // Got the idea for the next four methods from 1ManStartup on YouTube. His two videos on Google Places
  @override
  void initState() {
    super.initState();
    myControllerAddr.addListener(_onSearchChanged);
    _placesList = ["This", "is", "where", "address", "will be"];
  }

  // this is so that all controllers are done when this route (page) is exited
  @override
  void dispose() {
    myControllerAddr.removeListener(_onSearchChanged);
    myControllerAddr.dispose();
    myControlMsg.dispose();
    myControlpub.dispose();
    myControlSport.dispose();
    super.dispose();
  }

  //_onSearchChanged is so that a new sessionToken can be assigned to the new search
  // this way the company is not charged for each individual API search, but rather
  // charged for every session
  _onSearchChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
  }

  // A method for a custom Google Places Autocomplete request
  void displayPrediction(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String type = 'address';

    ///what type of autocomplete do we want?

    String request =
        '$baseURL?input=$input&key=$googlePlacesAPI&type=$type&sessiontoken=$_sessionToken';

    // send http request
    Response response = await Dio().get(request);

    // get the body of the response message
    final predictions = response.data['predictions'];

    // List for the results, and the below for loop is so each of the
    // five description elements (in this case addresses) of the predictions array
    // can be gathered and be displayed
    List<String> _displayedResults = [];

    for (var i = 0; i < predictions.length; i++) {
      String name = predictions[i]['description'];
      _displayedResults.add(name);
    }

    setState(() {
      //Set the _placesList to the returned list of addresses
      _placesList = _displayedResults;
    });
  }

  // Function to create a new game and add to the firestore database.
  void creategame(Timestamp _endtime, GeoFirePoint _location, String _note, int _playersneeded, bool _private, String _sport, Timestamp _starttime) {
    //Geoflutterfire geo = Geoflutterfire();
    //GeoFirePoint point = geo.point(latitude: _location.latitude, longitude: _location.longitude);
    
    Game game = new Game(
      endtime: _endtime,
      geoLocation: _location,
      location: _location.geoPoint,
      note: _note,
      playersneeded: _playersneeded,
      private: _private,
      sport: _sport,
      starttime: _starttime,
    );
    instance.addgame(game.toMap());
    //Firestore.instance.collection('Games').add({'endtime': game.endtime, 'location':_location, 'position': game.location, 'note': game.note, 'playersneeded': game.playersneeded, 'private': game.private, 'sport': game.sport, 'endtime': game.endtime});
  }

  // this is so Text Widgets do not have to be re-written multiple times in the Widget build method
  Container text(String key, double maxWidth) {
    return Container(
        child: Text(
          key,
          style: TextStyle(fontSize: 20),
        ),
        constraints: BoxConstraints(
            maxHeight: 50.0,
            minHeight: 50.0,
            maxWidth: maxWidth,
            minWidth: 50.0),
        alignment: Alignment.center);
  }

  //This method is for changing the selected address into coordinates.
  // First it builds the URL needed to changed the address
  // Then assigns the response message body to the results variable
  // Then breaks down the body to the coordinates we need by splitting and deleting
  //    many words and symbols
  void getCoordinates(String placesAddr) async {
    String addrURL = placesAddr.replaceAll(" ", "+");
    String requestURL =
        "https://maps.googleapis.com/maps/api/geocode/json?key=$googlePlacesAPI&address=$addrURL";
    Response response = await Dio().get(requestURL);
    final results = response.data['results'];

    List<String> res = results
        .toString()
        .split('location: ')
        .toList()[1]
        .split('location_type')
        .toList()[0]
        .replaceAll("[", "")
        .replaceAll("lat:", "")
        .replaceAll("{", "")
        .replaceAll("},", "")
        .replaceAll(" lng:", "")
        .split(", ");

    var latitude = double.parse(res[0]);
    var longitude = double.parse(res[1]);

    _location = GeoFirePoint(latitude, longitude);
  }

  //For the list tiles of the list view for the google places search
  Widget buildListCard(BuildContext context, int index) {
    return Card(
        child: ListTile(
      title: Text(_placesList[index]),
      onTap: () {
        //function to get the coordinates from selected address
        getCoordinates(_placesList[index]);
        setState(() {
          myControllerAddr.text = _placesList[
              index]; //This way the textfield has the selected address showing
        });
      },
    ));
  }

  ///For the selection of bottom nav items
   void _onBotNavTap(int index) {
      newRoute(index, context);
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
                text("Address:", 100.0),
                Container(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Enter Address Here'),
                    controller: myControllerAddr,
                    onChanged: (text) {
                      displayPrediction(text);
                    },
                  ),
                  constraints: BoxConstraints(
                      maxHeight: 50.0,
                      maxWidth: 300.0,
                      minHeight: 50.0,
                      minWidth: 50.0),
                ),
              ],
            ),
            Row(
              ///To create the List of Addresses from Google Places
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 100.0,
                    child: ListView.builder(
                      itemCount: _placesList.length,
                      itemBuilder: (BuildContext context, int index) =>
                          buildListCard(context, index),
                    ),
                  ),
                )
              ],
            ),

            ///time and date row
            Row(
              children: <Widget>[
                text("Time/Date:", 100.0),
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
              text("Sport:", 100.0),
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
                text("Private or Public Match?", 200.0),
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
                text("# of players: ", 100.0),
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
          ],
        ),
      ),
      // the submit button
      floatingActionButton: FloatingActionButton(
        onPressed: _updateData,
        tooltip: 'Increment',
        child: Text('Submit'),
      ),
      bottomNavigationBar: botNavBar(2, _onBotNavTap, context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
