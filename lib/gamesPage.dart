import 'package:flutter/material.dart';
import 'package:pickup_app/gameFeed.dart';

import 'filterPage.dart';
import 'findGameMap.dart';
import 'locationPage.dart';

class GamesPage extends StatefulWidget {
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  /// Set to `true` to show games in the feed, set to `false` to show games in the map.
  bool _showGameFeed = true;

  /// Updates the value of [_showGameFeed] using [setState].
  void shouldShowGameFeed(bool showFeed) {
    setState(() {
      this._showGameFeed = showFeed;
    });
  }

  @override
  // The main body for the game feed. Uses a column to manage multiple widgets in the body.
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            child: Row(
                // Filter by location (current or specified).
                // Show different widgets in row based on the value selected
                children: _showGameFeed
                    ? <Widget>[
                        FlatButton(
                          onPressed: () => Navigator.of(context)
                              .push(_createRoute(LocationPage())),
                          child: Icon(Icons.edit_location),
                        ),

                        // Choose how to view games. Either in list or map form.
                        Expanded(
                          child: ButtonBar(
                            alignment: MainAxisAlignment.center,
                            buttonMinWidth: 80.0,
                            children: <Widget>[
                              RaisedButton(
                                onPressed: () => shouldShowGameFeed(true),
                                child: Text(
                                  'List',
                                ),
                              ),
                              RaisedButton(
                                onPressed: () => shouldShowGameFeed(false),
                                child: Text(
                                  'Map',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Filter by game type (e.g. Basketball, Football, etc.), time, etc.

                        FlatButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(_createRoute(FilterPage()));
                          },
                          child: Icon(Icons.filter_list),
                        )
                      ]
                    : <Widget>[
                        // Choose how to view games. Either in list or map form.
                        FlatButton(
                          onPressed: () => Navigator.of(context)
                              .push(_createRoute(LocationPage())),
                          child: Icon(Icons.edit_location),
                        ),
                        Expanded(
                          child: ButtonBar(
                            alignment: MainAxisAlignment.center,
                            buttonMinWidth: 80.0,
                            children: <Widget>[
                              RaisedButton(
                                onPressed: () => shouldShowGameFeed(true),
                                child: Text(
                                  'List',
                                ),
                              ),
                              RaisedButton(
                                onPressed: () => shouldShowGameFeed(false),
                                child: Text(
                                  'Map',
                                ),
                              ),
                            ],
                          ),
                        ),
                        FlatButton(
                          child: Icon(Icons.filter_list),
                        )
                        // Filter by game type (e.g. Basketball, Football, etc.), time, etc.
                      ]),
          ),
          // Determine which Widget to show on game feed route.
          _showGameFeed
              ? Expanded(
                  child: SizedBox(
                  height: 200.0,
                  child: new GameFeed(),
                ))
              : Expanded(
                  child: SizedBox(height: 200.0, child: new FindGameMap())),
        ],
      ),
    );
  }

  /// Custom route transition that animates the page from the bottom of the screen. This function
  /// returns a PageRouteBuilder.
  ///
  /// The [page] parameter must not be null. It should be a valid constructor for a route.
  Route _createRoute(page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondartAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
