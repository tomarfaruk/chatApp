import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findfriend/core/models/chatModel.dart';
import 'package:findfriend/core/models/user.dart';

class RecentUsersService {
  Firestore firestore = Firestore.instance;

  final CollectionReference _messageCollectionReference =
      Firestore.instance.collection('recentChat');

  final StreamController<List<Chat>> _msgController =
      StreamController<List<Chat>>.broadcast();

  // #6: Create a list that will keep the paged results
  List<List<Chat>> _allPagedResults = List<List<Chat>>();

  static const int PostsLimit = 100;

  DocumentSnapshot _lastDocument;
  bool _hasMorePosts = true;

  Stream listenToUsersRealTime(User currentUser) {
    // Register the handler for when the posts data changes
    _requestUser(currentUser);

    return _msgController.stream;
  }

  // #1: Move the request posts into it's own function
  void _requestUser(User currentUser) {
    // #2: split the query from the actual subscription
    var pagePostsQuery = _messageCollectionReference
        .where("queryIDs", arrayContains: currentUser.id)
        .orderBy('time', descending: true)
        .limit(PostsLimit);

    // #5: If we have a document start the query after it
    if (_lastDocument != null) {
      pagePostsQuery = pagePostsQuery.startAfterDocument(_lastDocument);
    }

    if (!_hasMorePosts) return;

    // #7: Get and store the page index that the results belong to
    var currentRequestIndex = _allPagedResults.length;

    pagePostsQuery.snapshots().listen((postsSnapshot) {
      if (postsSnapshot.documents.isNotEmpty) {
        var posts = postsSnapshot.documents
            .map((snapshot) => Chat.fromJson(snapshot.data))
            .toList();

        // #8: Check if the page exists or not
        var pageExists = currentRequestIndex < _allPagedResults.length;

        // #9: If the page exists update the posts for that page
        if (pageExists) {
          _allPagedResults[currentRequestIndex] = posts;
        }
        // #10: If the page doesn't exist add the page data
        else {
          _allPagedResults.add(posts);
        }

        // #11: Concatenate the full list to be shown
        var allPosts = _allPagedResults.fold<List<Chat>>(List<Chat>(),
            (initialValue, pageItems) => initialValue..addAll(pageItems));

        // #12: Broadcase all posts
        _msgController.add(allPosts);

        // #13: Save the last document from the results only if it's the current last page
        if (currentRequestIndex == _allPagedResults.length - 1) {
          _lastDocument = postsSnapshot.documents.last;
        }

        // #14: Determine if there's more posts to request
        _hasMorePosts = posts.length == PostsLimit;
      } else {
        if (_allPagedResults.length == 0) {
          _msgController.add([]);
        }
      }
    });
  }

  void requestMoreUser(User currentUser) => _requestUser(currentUser);
}
