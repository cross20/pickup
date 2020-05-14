import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'createGame.dart';
import 'game.dart';
import 'gameDetailsPage.dart';
import 'globals.dart';

class Games {
  Games();

  /// Gets all of the games for a user and stores them in a [List<Game>].
  List<Game> getUserGames(List<DocumentSnapshot> games, String userId) {
    List<Game> userGames = new List<Game>();

    // Convert every game from the database to a Game object.
    for (DocumentSnapshot doc in games) {
      Game g = Game.fromFirestore(doc);
      if (g.userId == userId) {
        Game.fromFirestore(doc);
      }
    }

    return userGames;
  }

  /// Takes games for a list of [DocumentSnapshot] objects, converts them to game objects,
  /// and then removes games that the filter indicates should not be included in the results.
  Future<List<Game>> getFilteredGames(List<DocumentSnapshot> list) async {
    List<Game> games = new List<Game>();

    // Convert every game from the database to a Game object.
    for (DocumentSnapshot doc in list) {
      games.add(Game.fromFirestore(doc));
    }

    if (!filter.baseball.value) {
      games.removeWhere((Game g) => g.sport == "Baseball");
    }

    if (!filter.basketball.value) {
      games.removeWhere((Game g) => g.sport == "Basketball");
    }

    if (!filter.football.value) {
      games.removeWhere((Game g) => g.sport == "Football");
    }

    if (!filter.soccer.value) {
      games.removeWhere((Game g) => g.sport == "Soccer");
    }

    // Remove games that have already started.
    games
        .removeWhere((Game g) => g.starttime.toDate().isBefore(DateTime.now()));

    // Calculate the distance between the user's specified location and the game's location.
    for (Game g in games) {
      double distanceInMeters = await location.getDistanceBetweenPoints(
          location.location, g.location);
      g.distanceInMeters = distanceInMeters;
    }

    games.removeWhere((Game g) => g.distanceInMeters > location.rangeInMeters);

    games.sort((Game g1, Game g2) => g1.starttime.compareTo(g2.starttime));

    return games;
  }

  Future<String> createAlertDialog(BuildContext context, Game game) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Are you sure you want to delete this game?"),
            actions: <Widget>[
              MaterialButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              MaterialButton(
                child: Text("Yes"),
                onPressed: () {
                  Firestore.instance
                      .collection(dbCol)
                      .document(game.id)
                      .delete();
                  Navigator.of(context).pop(game.sport);
                },
              )
            ],
          );
        });
  }

  /// Formats game data in a [Card] providing an overview of game deatils. The included game
  /// details are: sport, start date, start time, and players needed. When [useEditMode] is
  /// false, the distance is excluded.
  ///
  /// The default value for [useEditMode] and [useMetricUnits] is false. Also, date and time
  /// information is formatted as <Date> at <Time>.
  Card getGameCard(
      {@required BuildContext context,
      @required Game game,
      DateFormat dateFormat,
      DateFormat timeFormat,
      bool canDelete,
      bool useMetricUnits}) {
    DateFormat date =
        (dateFormat != null ? dateFormat : new DateFormat('MMM d'));

    DateFormat time = (timeFormat != null
        ? timeFormat
        : (MediaQuery.of(context).alwaysUse24HourFormat)
            ? new DateFormat('hh:mm')
            : new DateFormat('hh:mm a'));

    useMetricUnits = (useMetricUnits != null ? useMetricUnits : false);
    canDelete = (canDelete != null ? canDelete : false);

    double distance = (useMetricUnits
        ? game.distanceInMeters / 1000
        : game.distanceInMeters / 1609.34);

    return new Card(
      child: ListTile(
        title: Text('${game.sport} Game'),
        subtitle: Text(
            '${date.format(game.starttime.toDate())} at ${time.format(game.starttime.toDate())},\n' +
                (canDelete
                    ? ''
                    : '${distance.toStringAsFixed(2)}' +
                        (useMetricUnits ? ' km away' : ' miles away') +
                        ',\n') +
                '${game.playersneeded} players needed.'),
        trailing: (canDelete
            ? new IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  createAlertDialog(context, game).then((name) {
                    if(name != null) {
                      SnackBar confirmDelete = SnackBar(
                          content: Text("Your $name game has been deleted."));
                      Scaffold.of(context).showSnackBar(confirmDelete);
                    }
                  });
                },
              )
            : Icon(Icons.chevron_right)),
        isThreeLine: !canDelete,
        contentPadding: canDelete
            ? EdgeInsets.fromLTRB(14, 10, 14, 10)
            : EdgeInsets.fromLTRB(14, 0, 14, 10),
        onTap: () {
          if (canDelete) {
            // TODO: Send the game to the correct game editing page.
            // TODO: Do everything that should happen when in edit mode.
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GameDetailsPage(game.id)));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GameDetailsPage(game.id)));
          }
        },
      ),
    );
  }
}
