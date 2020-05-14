import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'createGame.dart';
import 'game.dart';
import 'gamedetails.dart';
import 'globals.dart';

class Games {
  Games();

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
      bool useEditMode,
      bool useMetricUnits}) {
    DateFormat date =
        (dateFormat != null ? dateFormat : new DateFormat('MMM d'));

    DateFormat time = (timeFormat != null
        ? timeFormat
        : (MediaQuery.of(context).alwaysUse24HourFormat)
            ? new DateFormat('hh:mm')
            : new DateFormat('hh:mm a'));

    useMetricUnits = (useMetricUnits != null ? useMetricUnits : false);
    useEditMode = (useEditMode != null ? useEditMode : false);

    double distance = (useMetricUnits
        ? game.distanceInMeters / 1000
        : game.distanceInMeters / 1609.34);

    return new Card(
      child: ListTile(
        title: Text('${game.sport} Game'),
        subtitle: Text(
            '${date.format(game.starttime.toDate())} at ${time.format(game.starttime.toDate())},\n' +
                (useEditMode
                    ? ''
                    : '${distance.toStringAsFixed(2)}' +
                        (useMetricUnits ? ' km away' : ' miles away') +
                        ',\n') +
                '${game.playersneeded} players needed.'),
        trailing: (useEditMode ? Icon(Icons.edit) : Icon(Icons.chevron_right)),
        isThreeLine: !useEditMode,
        contentPadding: useEditMode
            ? EdgeInsets.fromLTRB(14, 10, 14, 10)
            : EdgeInsets.fromLTRB(14, 0, 14, 10),
        onTap: () {
          if (useEditMode) {
            // TODO: Send the game to the correct game editing page.
            // TODO: Do everything that should happen when in edit mode.
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateGamePage()));
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
