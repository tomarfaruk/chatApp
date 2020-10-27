import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findfriend/core/models/chatModel.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/ui/const.dart';

class FirestoreService {
  Firestore firestore = Firestore.instance;

  final CollectionReference _userCollectionReference =
      Firestore.instance.collection('users');
  final StreamController<List<User>> _userController =
      StreamController<List<User>>.broadcast();

  List<User> _allUserList = List<User>();

  DocumentSnapshot _lastUserDocument;
  bool _hasMoreUsers = true;

  Stream listenToUserRealTime() {
    _requestUsers();
    return _userController.stream;
  }

  void _requestUsers() {
    var pagePostsQuery =
        _userCollectionReference.orderBy('displayName').limit(PostsLimit);

    // #5: If we have a document start the query after it
    if (_lastUserDocument != null) {
      pagePostsQuery = pagePostsQuery.startAfterDocument(_lastUserDocument);
    }

    if (!_hasMoreUsers) return;
    print(_hasMoreUsers);

    pagePostsQuery.snapshots().listen((postsSnapshot) {
      _hasMoreUsers = postsSnapshot.documents.length == PostsLimit;

      if (postsSnapshot.documents.isNotEmpty) {
        var posts = postsSnapshot.documents
            .map((snapshot) => User.fromJson(snapshot.data))
            .toList();

        _allUserList.addAll(posts);

        final seen = Set<String>();
        final allPosts = _allUserList.where((str) => seen.add(str.id)).toList();

        _userController.add(allPosts);

        _lastUserDocument = postsSnapshot.documents.last;
      } else {
        if (_allUserList.length == 0) {
          _userController.add([]);
        }
      }
    });
  }

  void requestMoreUser() => _requestUsers();

  final CollectionReference _messageCollectionReference =
      Firestore.instance.collection('messages');

  final StreamController<List<Chat>> _msgController =
      StreamController<List<Chat>>.broadcast();

  // #6: Create a list that will keep the paged results
  List<List<Chat>> _allPagedResults = List<List<Chat>>();

  static const int PostsLimit = 25;

  DocumentSnapshot _lastDocument;
  bool _hasMorePosts = true;

  Stream listenToPostsRealTime(User currentUser, User friend) {
    // Register the handler for when the posts data changes
    _requestPosts(currentUser, friend);

    return _msgController.stream;
  }

  // #1: Move the request posts into it's own function
  void _requestPosts(User currentUser, User friend) {
    String uid = getUniqueId(friend.id, currentUser.id);
    // #2: split the query from the actual subscription
    var pagePostsQuery = _messageCollectionReference
        .where("msgId", isEqualTo: uid)
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
        if (_allPagedResults.length == 0) _msgController.add([]);
      }
    });
  }

  void requestMoreData(User currentUser, User friend) =>
      _requestPosts(currentUser, friend);

  Future<bool> sendMessage(Chat chat) async {
    try {
      Firestore fireStore = Firestore.instance;
      String id = getUniqueId(chat.me.id, chat.friend.id);
      print("ID $id");
      chat.msgId = id;
      fireStore.collection("messages").add(chat.toJson());
      // await saveRecentChat(chat);
      return true;
    } catch (e) {
      print("Exception $e");
      return false;
    }
  }
}
