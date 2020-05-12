import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pickup_app/globals.dart';
import 'package:uuid/uuid.dart';

class LocationPage extends StatefulWidget {
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _searchBarController = TextEditingController();
  String _googlePlacesAPI = "AIzaSyBQTQwCWEASIKWsXPXyOx70kAenVJgrSA0";
  Uuid _uuid = new Uuid();
  String _sessionToken;
  List<String> _searchResults = new List<String>();
  GeoPoint _selectedLocation;

  void initState() {
    super.initState();
    _selectedLocation = filter.location.value;
    _searchBarController.addListener(() {
      if (_searchBarController.text == '') {
        _searchResults.clear();
      } else {
        _searchResults.add('Current location');
      }

      if (_sessionToken == null) {
        setState(() {
          _sessionToken = _uuid.v4();
        });
      }
    });
  }

  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  /// Generates a new list from [values] and sets [_searchResults] equal to this new list.
  void updateListView(List<String> values) {
    setState(() {
      _searchResults = List.from(values);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Icon(Icons.close)),
            Spacer(),
            FlatButton(
                onPressed: () {
                  filter.location.value = _selectedLocation;
                  Navigator.pop(context);
                },
                child: Icon(Icons.done)),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('Searching for results near: ${_selectedLocation.latitude.toString()}, ${_selectedLocation.longitude.toString()}.'),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextFormField(
                controller: _searchBarController,
                onChanged: (String text) {
                  displayPrediction(text);
                },
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                  hintText: 'Enter an address',
                ),
              ),
            ),
            Expanded(
                child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: _searchResults.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              title: Text(_searchResults[index]),
                              onTap: () {
                                if (index == 0) {
                                  // TODO: Get the current location of the user.
                                } else {
                                  setLocationFromAddress(_searchResults[index]);
                                }
                              },
                            ),
                          );
                        })))
          ],
        ));
  }

  /// Predicts the top 5 most likely addresses that match [input] and replaces
  /// [_searchResults] with a new list generated from the predicted addresses. The generated
  /// addresses are stored as [String] values.
  void displayPrediction(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    // what type of autocomplete do we want?
    String type = 'address';

    String request =
        '$baseURL?input=$input&key=$_googlePlacesAPI&type=$type&sessiontoken=$_sessionToken';

    // send http request
    Response response = await Dio().get(request);

    // get the body of the response message
    final predictions = response.data['predictions'];

    // clear list for new elements
    _searchResults.clear();
    _searchResults.add('Current location');

    // add new elements
    for (var i = 0; i < predictions.length; i++) {
      String name = predictions[i]['description'];
      _searchResults.add(name);
    }

    updateListView(_searchResults);
  }

  /// Converts an address represented as a [String] into a [GeoPoint] and sets the
  /// [_selectedLocation] variable using the [GeoPoint].
  Future<void> setLocationFromAddress(String placesAddr) async {
    String googlePlacesAPI = "AIzaSyBQTQwCWEASIKWsXPXyOx70kAenVJgrSA0";
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

    _selectedLocation = GeoPoint(latitude, longitude);
  }
}
