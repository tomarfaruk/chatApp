import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';

class FindUserByLocationProvider extends ChangeNotifier {
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  Location location = new Location();

  List<User> _userList = List<User>();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  double radius = 1.0;
  changeRadius(double value) {
    radius = value;
    notifyListeners();
    if (_locationData != null) startQuery(_locationData);
  }

  Future getLocation(User me) async {
    // if (_locationData != null) return _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    await updateUserLocation(_locationData, me);
    return _locationData;
  }

  Future updateUserLocation(LocationData locationData, User me) {
    DocumentReference documentReference =
        Firestore.instance.collection("users").document(me.id);

    GeoFirePoint myLocation = geo.point(
        latitude: locationData.latitude, longitude: locationData.longitude);

    me.rewardAd -= 1;
    var json = me.toJson();
    json['location'] = myLocation.data;
    documentReference.setData(json, merge: true);
  }

  startQuery(LocationData pos) {
    // Create a geoFirePoint
    GeoFirePoint center =
        geo.point(latitude: pos.latitude, longitude: pos.longitude);

// get the collection reference or query
    final CollectionReference collectionReference =
        Firestore.instance.collection('users');

    String field = 'location';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field, strictMode: true);

    stream.listen((event) {
      if (event.isNotEmpty) {
        _userList = event.map((e) => User.fromJson(e.data)).toList();
        _userList = _userList.toSet().toList();

        _userController.add(_userList);

        print(_userList);
      } else {
        _userController.add([]);
      }
    });
  }

  final StreamController<List<User>> _userController =
      StreamController<List<User>>.broadcast();

  // Stream fstream = _radius.stream;

  Stream listenToUserRealTime(LocationData pos) {
    // Register the handler for when the posts data changes
    startQuery(pos);
    return _userController.stream;
  }
}
