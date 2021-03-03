import 'dart:io';
import 'dart:math';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:clock/clock.dart';

// https://github.com/CodingInfinite/animateMarkerWithCurrentLocation/blob/master/app/src/main/java/com/spartons/animatingmarkercurrentlocation/MarkerAnimation.java
//https://codinginfinite.com/android-example-animate-marker-map-current-location/
//https://stackoverflow.com/questions/40526350/how-to-move-marker-along-polyline-using-google-map
class MarkerAnimation {

  static double toRadians(double angdeg) {
    return angdeg / 180.0 * PI;
  }

  static double toDegrees(double angrad) {
    return angrad * 180.0 / PI;
  }

  static double computeAngleBetween(LatLng from, LatLng to) {
    return distanceRadians(toRadians(from.latitude), toRadians(from.longitude),
        toRadians(to.latitude), toRadians(to.longitude));
  }

  /**
   * Returns haversine(angle-in-radians).
   * hav(x) == (1 - cos(x)) / 2 == sin(x / 2)^2.
   */
  static double hav(double x) {
    double sinHalf = sin(x * 0.5);
    return sinHalf * sinHalf;
  }

  /**
   * Computes inverse haversine. Has good numerical stability around 0.
   * arcHav(x) == acos(1 - 2 * x) == 2 * asin(sqrt(x)).
   * The argument must be in [0, 1], and the result is positive.
   */
  static double arcHav(double x) {
    return 2 * asin(sqrt(x));
  }

  static double distanceRadians(double lat1, double lng1, double lat2, double lng2) {
    return arcHav(havDistance(lat1, lat2, lng1 - lng2));
  }

  static double havDistance(double lat1, double lat2, double dLng) {
    return hav(lat1 - lat2) + hav(dLng) * cos(lat1) * cos(lat2);
  }

  static LatLng interpolate(LatLng from, LatLng to, double fraction) {
    // http://en.wikipedia.org/wiki/Slerp
    double fromLat = toRadians(from.latitude);
    double fromLng = toRadians(from.longitude);
    double toLat = toRadians(to.latitude);
    double toLng = toRadians(to.longitude);
    double cosFromLat = cos(fromLat);
    double cosToLat = cos(toLat);

    // Computes Spherical interpolation coefficients.
    double angle = computeAngleBetween(from, to);
    double sinAngle = sin(angle);
    if (sinAngle < 1E-6) {
      return new LatLng(
          from.latitude + fraction * (to.latitude - from.latitude),
          from.longitude + fraction * (to.longitude - from.longitude));
    }
    double a = sin((1 - fraction) * angle) / sinAngle;
    double b = sin(fraction * angle) / sinAngle;

    // Converts from polar to vector and interpolate.
    double x = a * cosFromLat * cos(fromLng) + b * cosToLat * cos(toLng);
    double y = a * cosFromLat * sin(fromLng) + b * cosToLat * sin(toLng);
    double z = a * sin(fromLat) + b * sin(toLat);

    // Converts interpolated vector back to polar.
    double lat = atan2(z, sqrt(x * x + y * y));
    double lng = atan2(y, x);
    return new LatLng(toDegrees(lat), toDegrees(lng));
  }

  static double getInterpolation(double input) {
    return (cos((input + 1) * PI) / 2.0) + 0.5;
  }
  // TODO Das geht nicht, da das die Karte sperrt


}