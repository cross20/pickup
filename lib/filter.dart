import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Manages which data from the database should be presented to the user.
///
/// This does not perform queries on the database but should be used in pair with database
/// queries to determine which data is appropriate to present.
///
/// Currently, filtering by [sport] is the only supported filter.
class Filter {
  // Public member variables.

  /// Set the [value] property to `true` to include all games of type [baseball].
  ValueNotifier<bool> baseball;

  /// Set the [value] property to `true` to include all games of type [basketball].
  ValueNotifier<bool> basketball;

  /// Set the [value] property to `true` to include all games of type [football].
  ValueNotifier<bool> football;

  /// Set the [value] property to `true` to include all games of type [soccer].
  ValueNotifier<bool> soccer;

  ValueNotifier<GeoPoint> location;

  /// Default constructor for [Filter] where all values are `true` by default.
  Filter() {
    baseball = ValueNotifier<bool>(true);
    basketball = ValueNotifier<bool>(true);
    football = ValueNotifier<bool>(true);
    soccer = ValueNotifier<bool>(true);
    location = ValueNotifier<GeoPoint>(new GeoPoint(47, 117)); // TODO: Use the user's current location.
  }

  /// Sets the values of each filter parameter. Use `true` to include a parameter in the results.
  void include(bool baseball, bool basketball, bool football, bool soccer) {
    this.baseball.value = baseball;
    this.basketball.value = basketball;
    this.football.value = football;
    this.soccer.value = soccer;
  }

  /// Listens to changes on any parameter in this class. It does this by merging all parameters into
  /// one [Listenable] object.
  Listenable allValues() {
    final List<ValueNotifier<bool> > values = [baseball, basketball, football, soccer];

    // Do not modify [values] after merging. Doing so will cause memory leaks.
    return Listenable.merge(values);
  }
}
