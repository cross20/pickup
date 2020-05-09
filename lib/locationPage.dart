import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class LocationPage extends StatefulWidget {
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _searchBarController = TextEditingController();
  List<String> _searchResults = new List<String>();
  String _googlePlacesAPI = "AIzaSyBQTQwCWEASIKWsXPXyOx70kAenVJgrSA0";
  String _sessionToken;

  void initState() {
    super.initState();
    _searchBarController.addListener(() {
      // TODO: The controller prevents the backspace character from working.
      final text = _searchBarController.text;
      _sessionToken = Uuid().v4();
      displayPrediction(text);
      _searchBarController.value = _searchBarController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  void dispose() {
    _searchBarController.dispose();
    super.dispose();
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
            FlatButton(onPressed: null, child: Icon(Icons.done)),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextFormField(
                controller: _searchBarController,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.location_searching),
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
                            ),
                          );
                        })))
          ],
        ));
  }

    // A method for a custom Google Places Autocomplete request
  void displayPrediction(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    ///what type of autocomplete do we want?
    String type = 'address';

    String request =
        '$baseURL?input=$input&key=$_googlePlacesAPI&type=$type&sessiontoken=$_sessionToken';

    // send http request
    Response response = await Dio().get(request);

    // get the body of the response message
    final predictions = response.data['predictions'];

    //clear list for new elements
    _searchResults.clear();

    // add new elements
    for (var i = 0; i < predictions.length; i++) {
      String name = predictions[i]['description'];
      _searchResults.add(name);
    }
  }
}
