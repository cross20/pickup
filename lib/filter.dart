/// Manages which data from the database should be presented to the user.
///
/// This does not perform queries on the database but should be used in pair with database
/// queries to determine which data is appropriate to present.
///
/// Currently filtering by [sport] is the only supported filter.
class Filter {
  // Public member variables.

  /// Set to `true` to include all games of type [baseball].
  bool baseball;

  /// Set to `true` to include all games of type [basketball].
  bool basketball;

  /// Set to `true` to include all games of type [football].
  bool football;

  /// Set to `true` to include all games of type [soccer].
  bool soccer;

  /// Default constructor for [Filter] where all values are `true` by default.
  Filter() {
    baseball = true;
    basketball = true;
    football = true;
    soccer = true;
  }

  /// Sets the values of each filter parameter. Use `true` to include a parameter in the results.
  void include(bool baseball, bool basketball, bool football, bool soccer) {
    this.baseball = baseball;
    this.basketball = basketball;
    this.football = football;
    this.soccer = soccer;
  }
}
