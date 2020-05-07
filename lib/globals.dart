library pickup.globals;
import 'filter.dart';
//import 'authroot.dart';

/// Handles which results should be shown from the database. This should only be used to filter
/// results for the entire app.
Filter filter = Filter();

/// The name in the database of the collection where [Game] objects are found.
String dbCol = 'GamesGeoQuery';

String userId = "Defaultest";