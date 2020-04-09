import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pickup_app/appUI.dart';
import 'findGameMap.dart';


class GameFeed extends StatefulWidget {
  GameFeed({Key key, this.title}) : super(key: key);

  final String title;

  _GameFeedState createState() => _GameFeedState();
}

class _GameFeedState extends State<GameFeed> {
  bool _list = true;

  @override
  initState(){
    super.initState();
    _list = true;
  }

  void setList(bool list){
    setState(() {
      _list = list;
    });
  }

  // Formats the content that will appear in the list item by item. The content is formatted
  // using a container object.
  Widget listBody(BuildContext context, DocumentSnapshot document) {
    return new Card(
      child: ListTile(
        title: Text(document['sport']),
        subtitle: Text('${document.documentID}'),
      ),
    );
  }


  ///Function to determine with Widget to show on game feed route. If _list is set to true (i.e,
  /// the List Button was last selected, then show list, else show map)
  Widget listOrMap (){
    if (_list == true){
      //Display list
      return 
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection('Games').snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return const Text('Loading...');
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) => listBody(context, snapshot.data.documents[index])
                  );
                },
              )
            );
    }
    else {
      //Display map
      return Expanded(child: SizedBox(height:200.0, child: new FindGameMap()));//Column(children: <Widget>[Text("This is for the map")],);
    }
  }

    ///This is to determine the new Route that must be selected
    /// to navigate to depending on which bottom nav button is selected 
    ///  newRoute() is defined in appUI.dart file
    void _onBotNavTap(int index) {
      newRoute(index, context);
    }


  // The main body for the game feed. Uses a column to manage multiple widgets in the body.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: //Center(
        //child:
        Column(
          children: <Widget>[
            Container(
              color: Colors.blue,
              child: Row(
                // Filter by location (current or specified).
                children: <Widget>[
                  FlatButton(
                    onPressed: null, // TODO: Display a search bar and keyboard to search for a location.
                    child: Text('Location'),
                  ),
                  // Choose how to view games. Either in list or map form.
                  Expanded(
                    child: ButtonBar(
                      alignment: MainAxisAlignment.center,
                      buttonMinWidth: 80.0,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () => {
                            //set list bool to true
                            setList(true)
                          }, // TODO: Load the list view.
                          child: Text('List',),
                        ),
                        RaisedButton(
                          onPressed: () => {
                            setList(false)  
                          }, // TODO: Load the map view.
                          child: Text('Map',),
                        ),
                      ],
                    ),
                  ),
                  // Filter by game type (e.g. Basketball, Football, etc.), time, etc.
                  FlatButton(
                    onPressed: null, // TODO: Determine which filter options are needed and to display them.
                    child: Text('Filter'),
                  )
                ],
              ),
            ),
            listOrMap(),
          ],
        ), 
      bottomNavigationBar: botNavBar(0, _onBotNavTap, context), // botNavBAr() Defined in appUI.dart file
    )
    ;
  }
}