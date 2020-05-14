/////This is the game creation page
import 'game.dart';
import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:dio/dio.dart';
import 'appUI.dart';
import 'authentication.dart';
import 'authroot.dart';
import 'splashscreen.dart';
import 'package:dio/dio.dart';
import 'appUI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'user.dart';

import 'globals.dart' as globals;

// google places packages
import "package:google_maps_webservice/places.dart"; // for the GoogleMapPlaces
import 'package:uuid/uuid.dart'; //for session token

// Global Database linking to firestore
Database instance = new Database();

// this class is for initializing this page
class CreateGamePage extends StatefulWidget {
  CreateGamePage({Key key, this.title, this.userId: ""}) : super(key: key);

  final String title;
  String userId;

  _CreateGamePageState createState() =>
      _CreateGamePageState(userId: this.userId);
}

// this class is for setting the state of the page, it is stateful so widgets within this class can change.
// This class starts off by defining all the data types and methods I need to properly display and save all game data needed.
// Then the updateData() method is next, which is called when user hits submit, this is where the Game object is created
// and sent to the database.
// Finally is the build method, where all the Widgets are that are needed for this UI
class _CreateGamePageState extends State<CreateGamePage> {
  String userId;
  _CreateGamePageState({this.userId}) {}
  //Global Key for the form widgets
  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  // This is the Google Maps Place API
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: "AIzaSyBQTQwCWEASIKWsXPXyOx70kAenVJgrSA0");
  String googlePlacesAPI = "AIzaSyBQTQwCWEASIKWsXPXyOx70kAenVJgrSA0";

  //for the session ID token
  var uuid = new Uuid();
  String _sessionToken;
  List<String> _placesList = [];
  GeoFirePoint _location;

  //String for the selected sport
  String selectedSport = " ";

  ///controllers for listening to address, msg, sport, pub/priv input
  final myControllerAddr = TextEditingController(); //for the entered address
  final myControlMsg = TextEditingController(); // for the entered Message
  final myControlSport = TextEditingController(); // for sport selection
  final myControlpub = TextEditingController(); // for pub/priv match selection

  //init value of user inputted address
  String addr = " ";

  //init value of user inputted message
  String msg = " ";

  //Number of players wanted, init to 2
  int _currentNumPlay = 2;

  // List to store the 5 results from address search
  List<String> _displayedResults = [];

  //bool for pub vs priv match
  bool private = false;

  //init userId

  ///init values from Date and times of game
  var gameDate = DateTime.now();
  var startGameTime = DateTime.now();
  var endGameTime = DateTime.now();

  //When this page is first created, the _onSearchChanged is added to the
  // Address controller so that _onSearch can be called every time
  // user changes the input of address
  // Got the idea for the next four methods from 1ManStartup on YouTube. His two videos on Google Places
  @override
  void initState() {
    super.initState();
    myControllerAddr.addListener(_onSearchChanged);
  }

  // A method for a custom Google Places Autocomplete request
  void displayPrediction(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    ///what type of autocomplete do we want?
    String type = 'address';

    String request =
        '$baseURL?input=$input&key=$googlePlacesAPI&type=$type&sessiontoken=$_sessionToken';

    // send http request
    Response response = await Dio().get(request);

    // get the body of the response message
    final predictions = response.data['predictions'];

    //clear list for new elements
    _displayedResults.clear();

    // add new elements
    for (var i = 0; i < predictions.length; i++) {
      String name = predictions[i]['description'];
      _displayedResults.add(name);
    }
  }


    
  
  // Function to create a new game and add to the firestore database.
  void creategame(
      Timestamp _endtime,
      GeoFirePoint _location,
      String _addr,
      String _note,
      int _playersneeded,
      bool _private,
      String _sport,
      Timestamp _starttime,
      String _userId) {
    Game game = new Game(
        endtime: _endtime,
        geoLocation: _location,
        location: _location.geoPoint,
        note: _note,
        playersneeded: _playersneeded,
        private: _private,
        sport: _sport,
        starttime: _starttime,
        userId: _userId);
    instance.addgame(game.toMap());
    print("Id in game is" + userId);
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

  //This method is for changing the selected address into coordinates.
  // First it builds the URL needed to changed the address
  // Then assigns the response message body to the results variable
  // Then breaks down the body to the coordinates we need by splitting and deleting
  //    many words and symbols
  Future<void> getCoordinates(String placesAddr) async {
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

  /// this function is called when submit button is hit, this is where values are updated and casted to proper data type
  /// to be sent to the server
  void _updateData() async {
    ///to pass in the timestamp of both startGameTime and endGameTime,
    Timestamp _starttime = Timestamp.fromDate(startGameTime);
    Timestamp _endtime = Timestamp.fromDate(endGameTime);

    //function to get the coordinates from selected address
    await getCoordinates(myControllerAddr.text);

    //need to reset session token after submit button is selected
    _sessionToken = null;

      // A game will be pushed to the database everytime the "submit" button is clicked
      creategame(_endtime, _location, myControllerAddr.text, myControlMsg.text, _currentNumPlay,
          private, selectedSport, _starttime, userId);
  }

   
    
     
  // // Function to create a new game and add to the firestore database.
  // void creategame(Timestamp _endtime, GeoPoint _location, String _addr, String _note,
  //     int _playersneeded, bool _private, String _sport, Timestamp _starttime) {
  //   Game game = new Game(
  //     address: _addr,
  //     endtime: _endtime,
  //     location: _location,
  //     note: _note,
  //     playersneeded: _playersneeded,
  //     private: _private,
  //     sport: _sport,
  //     starttime: _starttime,
  //   );
  //   instance.addgame(game.toMap());
  // }

  ///For the selection of bottom nav items
  void _onBotNavTap(int index) {
    newRoute(index, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Game Page"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FormBuilder(
                // context,
                key: _fbKey,
                autovalidate: false,
                initialValue: {
                  'movie_rating': 5,
                },
                readOnly: false,
                child: Column(
                  children: <Widget>[
                    // Address input
                    FormBuilderTypeAhead(
                      decoration: InputDecoration(
                        labelText: "Address",
                      ),
                      attribute: 'address',
                      onChanged: (text) {
                        displayPrediction(text);
                      },
                      itemBuilder: (context, address) {
                        return ListTile(
                          title: Text(address),
                        );
                      },
                      controller: myControllerAddr,
                      initialValue: myControllerAddr.text,
                      suggestionsCallback: (address) {
                        if (address.length != 0) {
                          return _displayedResults.getRange(0, 3);
                        } else {
                          return null;
                        }
                      },
                    ),
                    //Date picker (Android)
                    FormBuilderDateTimePicker(
                      attribute: "date",
                      firstDate: DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day, 00, 00),
                      lastDate: DateTime(DateTime.now().year + 1),
                      inputType: InputType.date,
                      format: DateFormat("EEEE, MMMM d, yyyy"),
                      onChanged: (date) {
                        if (date != null)
                          {
                            gameDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                          }
                      },
                      decoration: InputDecoration(
                        labelText: "Date",
                        // helperText: "Helper text",
                        // hintText: "Hint text",
                      ),
                    ),
                    //start time (Android)
                    FormBuilderDateTimePicker(
                      attribute: "start time",
                      onChanged: (date) {
                        if (date != null)
                          {
                            startGameTime = DateTime(
                                gameDate.year,
                                gameDate.month,
                                gameDate.day,
                                date.hour,
                                date.minute,
                                00);
                          }
                      },
                      inputType: InputType.time,
                      format: DateFormat("h:mma"),
                      decoration: InputDecoration(
                        labelText: "Start Time",
                      ),
                      validator: (val) => null,
                      initialTime: TimeOfDay(hour: 12, minute: 0),
                    ),
                    //end time (Android)
                    FormBuilderDateTimePicker(
                      attribute: "end time",
                      onChanged: (date) {
                        if (date != null)
                          {
                            endGameTime = DateTime(
                                gameDate.year,
                                gameDate.month,
                                gameDate.day,
                                date.hour,
                                date.minute,
                                00);
                          }
                      },
                      inputType: InputType.time,
                      format: DateFormat("h:mma"),
                      decoration: InputDecoration(
                        labelText: "End Time",
                      ),
                      validator: (val) => null,
                      initialTime: TimeOfDay(hour: 12, minute: 0),
                    ),
                    //private match checkbox
                    FormBuilderCheckbox(
                      attribute: 'priv_or_pub',
                      initialValue: false,
                      onChanged: (checked) => {private = checked},
                      label: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Private Match?',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //Sport picker
                    FormBuilderRadio(
                      decoration: InputDecoration(
                          labelText: 'What sport will you be playing?'),
                      attribute: "sport_pick",
                      leadingInput: true,
                      onChanged: (sport) {
                        selectedSport = sport;
                      },
                      validators: [FormBuilderValidators.required()],
                      options: ["Basketball", "Soccer", "Football", "Baseball"]
                          .map((lang) => FormBuilderFieldOption(
                                value: lang,
                                child: Text('$lang'),
                              ))
                          .toList(growable: false),
                    ),
                    FormBuilderSlider(
                      attribute: "num_of_players",
                      onChanged: (number) {
                        double play = number;
                        _currentNumPlay = play.toInt();
                      },
                      min: 2,
                      max: 24,
                      initialValue: 2,
                      divisions: 22,
                      activeColor: Colors.red,
                      inactiveColor: Colors.pink[100],
                      numberFormat: NumberFormat("#0", "en_US"),
                      decoration: InputDecoration(
                        labelText: "Number of players wanted",
                        border: InputBorder.none,
                      ),
                    ),
                    FormBuilderTextField(
                      attribute: "message",
                      controller: myControlMsg,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Any special notes or criteria?"),
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                      _updateData();
                     _fbKey.currentState.reset();
                    
                      
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: MaterialButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        "Reset",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          myControllerAddr.clear();
                        });
                        _fbKey.currentState.reset();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

///Date Picker for iOS
/* FormBuilderCustomField(
                      attribute: "date_ios",
                      validators: [
                        FormBuilderValidators.required(),
                      ],
                      formField: FormField(
                        enabled: true,
                        builder: (FormFieldState<dynamic> field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Date (iOS)",
                              contentPadding:
                                  EdgeInsets.only(top: 10.0, bottom: 0.0),
                              border: InputBorder.none,
                              errorText: field.errorText,
                            ),
                            child: Container(
                              height: 100,
                              child: FlatButton(

                      ///date button
                      onPressed: () {
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            minTime: DateTime(DateTime.now().year,
                                DateTime.now().month, DateTime.now().day),
                            maxTime: DateTime(DateTime.now().year, 12, 31), 
                            onChanged: (date) {
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
                          );
                        },
                      ),
                    ),*/
