import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  late String _lat = '';
  late String _long = '';

  late String _address = "";

  late LatLng latLong;

  LocationProvider() {
    latLong = const LatLng(0, 0);
  }

  String get lat => _lat;
  String get long => _long;

  setLatLong(double lat, double long) {
    _lat = lat.toString();
    _long = long.toString();

    latLong = LatLng(lat, long);
    notifyListeners();
  }

  set setAddress(String address) {
    _address = address;
    notifyListeners();
  }

  String get address => _address;
}

final locationProvider = ChangeNotifierProvider((ref) => LocationProvider());
