import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findfriend/core/models/user.dart';

class SearchUser {
  final CollectionReference _userCollectionReference =
      Firestore.instance.collection('users');

  final StreamController<List<User>> _userController =
      StreamController<List<User>>.broadcast();

  Stream listentUser(String name) {
    _requestUsers(name);
    return _userController.stream;
  }

  _requestUsers(String name) {
    var pagePostsQuery = _userCollectionReference
        .orderBy('displayName')
        .limit(50)
        .where("indexes", arrayContains: name);

    pagePostsQuery.snapshots().listen(
      (postsSnapshot) {
        if (postsSnapshot.documents.isNotEmpty) {
          var posts = postsSnapshot.documents
              .map((snapshot) => User.fromJson(snapshot.data))
              .toList();

          _userController.add(posts);
        } else
          _userController.add([]);
      },
    );
  }
}
