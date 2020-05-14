library pickup.globals;

import 'filter.dart';
import 'location.dart';

/// Handles which results should be shown from the database. This should only be used to filter
/// results for the entire app.
Filter filter = Filter();

/// The location specified by the user. The default value is the user's location. If the
/// location has not yet been determined (or cannot be determined), the default value is null.
Location location = Location();

/// The name in the database of the collection where [Game] objects are found.
String dbCol = 'Games';
//String dbCol = 'GamesGeoQuery';

String userId = "Defaultest";
String profileId = "DefaultProfile";
