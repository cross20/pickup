import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

/////This is the game creation page
import 'game.dart';
import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
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
  GeoPoint _location;

  //String for the selected sport
  String selectedSport = " ";

  ///controllers for listening to address, msg, sport, pub/priv input
  final myControllerAddr = TextEditingController(); //for the entered address
  final myControlMsg = TextEditingController(); // for the entered Message
  final myControlSport = TextEditingController(); // for sport selection
  final myControlpub = TextEditingController(); // for pub/priv match selection

  //placeholder for addr controller text
  String addr = " ";

  //placeholder for msg controller text
  String msg = " ";

  //Number of players wanted, init to 2
  int _currentNumPlay = 2;

  // List to store the 5 results from address search
  List<String> _displayedResults = [];

  // List to store place_id of results
  List<String> _placeIDs = [];

  /// auto validation key
  bool _autovalidate = false;

  //bool for pub vs priv match
  bool private = false;

  ///init values from Date and times of game
  var gameDate = DateTime(1980);
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
  // inspired from 1ManStartup on Youtube
  Future<List<String>> displayPrediction(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    //type string for type of search
    // request string for rest of url
    String type;
    String request;

    ///Regex to search for starting numbers
    RegExp addrStart = RegExp(r'^[0-9-]$');

    ///Regex to search for starting letters
    RegExp estaStart = RegExp(r'[A-Za-z]');


    //Is search an address or establishment?
    if (addrStart.hasMatch(input.substring(0, 1))) {
      ///what type of autocomplete do we want?
      type = 'address';
      request =
          '$baseURL?input=$input&key=$googlePlacesAPI&type=$type&sessiontoken=$_sessionToken';
    } else if (estaStart.hasMatch(input.substring(0, 1))) {
      ///what type of autocomplete do we want?
      type = 'establishment';

      request =
          '$baseURL?input=$input&key=$googlePlacesAPI&type=$type&sessiontoken=$_sessionToken';
    }

    // send http request
    Response response = await Dio().get(request);

    // get the body of the response message
    final predictions = response.data['predictions'];

    //clear lists for new elements
    _displayedResults.clear();
    _placeIDs.clear();

    // add new elements
    for (var i = 0; i < predictions.length; i++) {
      //Add name
      String name = predictions[i]['description'];
      _displayedResults.add(name);

      //Add place_id
      String placeID = predictions[i]['place_id'];
      _placeIDs.add(placeID);
    }

    return _displayedResults;
  }


    
  
  // Function to create a new game and add to the firestore database.
  void creategame(
      Timestamp _endtime,
      GeoPoint _location,
      String _addr,
      String _note,
      int _playersneeded,
      bool _private,
      String _sport,
      Timestamp _starttime,
      String _userId) {
    Game game = new Game(
        endtime: _endtime,
        address: _addr,
        location: _location,
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
  // charged for every session (from 1ManStartup on Youtube)
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
    String requestURL =
        "https://maps.googleapis.com/maps/api/geocode/json?key=$googlePlacesAPI&place_id=$placesAddr";
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

    //convert from String to doubles
    var latitude = double.parse(res[0]);
    var longitude = double.parse(res[1]);

    _location = GeoPoint(latitude, longitude);
  }

  /// this function is called when submit button is hit, this is where values are updated and casted to proper data type
  /// to be sent to the server
  void _updateData() async {
    ///to pass in the timestamp of both startGameTime and endGameTime,
    Timestamp _starttime = Timestamp.fromDate(startGameTime);
    Timestamp _endtime = Timestamp.fromDate(endGameTime);

    //function to get the coordinates from selected address
    await getCoordinates(_placeIDs[_displayedResults.indexOf(addr)]);

    //need to reset session token after submit button is selected
    _sessionToken = null;

    // A game will be pushed to the database everytime the "submit" button is clicked
    creategame(_endtime, _location, addr, msg, _currentNumPlay, private,
        selectedSport, _starttime, userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create A Game"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FormBuilder(
                // based on example given at https://pub.dev/packages/flutter_form_builder
                // context,
                key: _fbKey,
                autovalidate: _autovalidate,
                readOnly: false,
                child: Column(
                  children: <Widget>[
                    // Address input
                    FormBuilderTypeAhead(
                      attribute: "place_input",
                      hideOnEmpty: true,
                      hideOnLoading: true,
                      decoration: InputDecoration(
                          labelText: "Where are you playing?",
                        ),
                      controller: myControllerAddr,
                      textFieldConfiguration: TextFieldConfiguration(
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (value) {
                          _displayedResults.clear();
                        },
                      ),
                      validators: [FormBuilderValidators.required(errorText: "Please enter a place to play"),
                      (value) {
                        if (value == null || value == "") {
                          return "Must enter a place to play.";
                        } else if (!_displayedResults
                            .contains(myControllerAddr.text)) {
                          return "Must select a valid place or address.";
                        }
                      },],
                      itemBuilder: (context, address) {
                        if (_displayedResults.isNotEmpty) {
                          return ListTile(
                            title: Text(address),
                          );
                        }
                        return ListTile(title: Text("No results found"));
                      },
                      onSuggestionSelected: (address) {
                        myControllerAddr.text = address;
                      },
                      suggestionsCallback: (address) async {
                        if (address.length != 0) {
                          /// call on Places request method here to 
                          /// populate the itemBuilder list
                          await displayPrediction(address);
                          if (_displayedResults.length >= 4) {
                            return _displayedResults.take(3);
                          } else if (_displayedResults.length < 4) {
                            return _displayedResults;
                          }
                        }
                      },
                    ),
                    //Date picker (Android)
                    FormBuilderDateTimePicker(
                      attribute: "date",
                      firstDate: DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day, 00, 00),
                      lastDate: DateTime(DateTime.now().year + 1),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: "Please select a date.")
                      ],
                      inputType: InputType.date,
                      format: DateFormat("EEEE, MMMM d, yyyy"),
                      onChanged: (date) {
                        if (date != null) {
                          gameDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                          );
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Date",
                      ),
                    ),
                    //start time (Android)
                    FormBuilderDateTimePicker(
                      validators: [FormBuilderValidators.required(errorText: "Please enter a start time"),
                        (value) {
                        // make sure start time is not after end time
                        if (startGameTime.isAfter(endGameTime)) {
                          return "Start time cannot be after end time.";
                        }
                        // make sure start time is not in the past
                        else if (startGameTime.isBefore(DateTime.now())) {
                          return "Start time cannot be in the past.";
                        }
                        // make sure start and end are not at same time
                        else if (startGameTime.isAtSameMomentAs(endGameTime)) {
                          return "Start and end time cannot be the same time.";
                        }
                      },],
                      attribute: "start_time",
                      onChanged: (date) {
                        if (date != null) {
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
                      initialTime: TimeOfDay(hour: 12, minute: 0),
                      format: DateFormat("h:mma"),
                      decoration: InputDecoration(
                        labelText: "Start Time",
                      ),
                    ),
                    //end time (Android)
                    FormBuilderDateTimePicker(
                      validators: [
                        FormBuilderValidators.required(errorText: "Please enter an end time"),
                        (value) {
                        if (endGameTime.isBefore(startGameTime)) {
                          return "End time cannot be before start time.";
                        } else if (endGameTime
                            .isAtSameMomentAs(startGameTime)) {
                          return "Start and end time cannot be the same time.";
                        } else if (endGameTime.isBefore(DateTime.now())) {
                          return "End time cannot be in the past.";
                        }
                        // Make sure games are at least an hour
                        else if (endGameTime
                                .difference(startGameTime)
                                .abs()
                                .inMinutes <
                            60) {
                          return "Game must at least one hour";
                        }
                      },],
                      attribute: "end_time",
                      onChanged: (date) {
                        if (date != null) {
                          endGameTime = DateTime(gameDate.year, gameDate.month,
                              gameDate.day, date.hour, date.minute, 00);
                        }
                      },
                      inputType: InputType.time,
                      initialTime: TimeOfDay(hour: 12, minute: 0),
                      format: DateFormat("h:mma"),
                      decoration: InputDecoration(
                        labelText: "End Time",
                      ),
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
                      validators: [
                        FormBuilderValidators.required(
                            errorText: "Please select a sport")
                      ],
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
                      activeColor: Colors.blue,
                      inactiveColor: Colors.lightBlueAccent[50],
                      numberFormat: NumberFormat("#0", "en_US"),
                      decoration: InputDecoration(
                        labelText: "Number of players wanted",
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
                        "Reset",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        _fbKey.currentState.reset();
                        myControllerAddr.clear();
                        myControlMsg.clear();
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Form reset")));
                        setState(() {
                          _autovalidate = false;
                        });
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
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        _fbKey.currentState.validate();
                        if (_fbKey.currentState.validate()) {
                          addr = myControllerAddr.text;
                          msg = myControlMsg.text;
                          _updateData();
                          _fbKey.currentState.reset();
                          //Clear address and message after creating game
                          myControllerAddr.clear();
                          myControlMsg.clear();
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Game has been created!')));
                        } else {
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid entrance')));
                          setState(() {
                            _autovalidate = true;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
