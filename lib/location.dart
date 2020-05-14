import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Location {

  /// The coordinates of [Location].
  GeoPoint location;

  /// Whether the user has enabled use of their current location.
  GeolocationStatus userLocationEnabled;

  /// The maximum distance a game should be within to be included in the game feed. The 
  /// default value is 32000 meters.
  double rangeInMeters;

  /// Stores the coordinates of the last known user location. Should only be used internally.
  GeoPoint _quickLocation;

  bool _quickLocationIsReady;

  /// Defult constructor for [Location] where [location] defaults to true.
  Location() {
    _initialize();
    rangeInMeters = 32000;
    _quickLocationIsReady = false;
  }

  /// Sets the coordinates of [location] to the user's current location. Set [quickLocation] to
  /// true to use the previously found current location rather than computing a new one. If a
  /// new current location is computed, the coordinates of the the previously found current
  /// location are updated. If there is no previously found current location, the current 
  /// location is computed.
  Future<void> setCurrentLocation(bool quickLocation) async {
    if (quickLocation && _quickLocationIsReady && _quickLocation != null) {
      location = _quickLocation;
    } else {
      location = await getCurrentLocation();
      _quickLocation = location;
    }
  }

  /// Sets [_quickLocation] so that setting the current location can be quicker. Use this when
  /// it is predicted that the user's current location will be needed soon. To utilize the
  /// quick location, call [setCurrentLocation] and set [quickLocation] to true.
  Future<void> prepareQuickLocatin() async {
    _quickLocationIsReady = false;
    _quickLocation = await getCurrentLocation();
    _quickLocationIsReady = true;
  }

  /// Computes and returns the coordinates of the user's current location.
  Future<GeoPoint> getCurrentLocation() async {
    // TODO: A faster way of retrieving the user's current location is needed!
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    
    return GeoPoint(position.latitude, position.longitude);
  }

  /// Converts a [GeoPoint] into an address. The retun value is the first value found by
  /// [Geolocator].
  Future<Placemark> getAddressFromPoint(GeoPoint point) async {
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(point.latitude, point.longitude);
    return placemark[0];
  }

  /// Computes the distance (in meters) between two [GeoPoint] objects.
  Future<double> getDistanceBetweenPoints(GeoPoint pointA, GeoPoint pointB) async {
    // TODO: A faster way to compute distances is needed!
    return await Geolocator().distanceBetween(pointA.latitude, pointA.longitude, pointB.latitude, pointB.longitude);
  }

  Future<void> _initialize() async {
    setCurrentLocation(false);
    userLocationEnabled = await Geolocator().checkGeolocationPermissionStatus();
  }
}
