import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:findfriend/core/services/findUserByLocationProvider.dart';
import 'package:findfriend/ui/screens/recentUsersScreen.dart';
import 'package:findfriend/ui/screens/search_screen.dart';
import 'package:findfriend/ui/widgets/custom_drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'chatScreen.dart';
import 'userByLocationScreen.dart';
import 'gengeralUserScree.dart';
import 'package:http/http.dart' as http;
import 'view_ads_screen.dart';

Future<dynamic> myBackgroundHandler(Map<String, dynamic> message) {
  return _HomeScreenState()._showNotification(message);
}

class HomeScreen extends StatefulWidget {
  static const routeName = "/HomeScreen";
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  String token;

  User me;
  Fbauth auth;
  double km = 1.0;

  int _pageIndex = 0;
  PageController _pageController;
  List<Widget> tabPages = [
    RecentUsersScreen(),
    GeneralUserScreen(),
    UserByLocationScreen(),
  ];

  FindUserByLocationProvider findUserByLocationProvider;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);

    auth = Provider.of<Fbauth>(context, listen: false);
    findUserByLocationProvider =
        Provider.of<FindUserByLocationProvider>(context, listen: false);
    me = auth.getMe;
    initialise();
    saveToken(me.id);
  }

  @override
  void dispose() async {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
          FlatButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (ctx) => SearchScreen())),
            child: Icon(Icons.search, size: 30, color: Colors.white),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: onTabTapped,
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user), title: Text("Recent")),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), title: Text("General")),
          BottomNavigationBarItem(
              icon: Icon(Icons.pin_drop), title: Text("NearBy")),
        ],
      ),
      body: PageView(
        children: tabPages,
        onPageChanged: onPageChanged,
        controller: _pageController,
      ),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      _pageIndex = page;
    });
  }

  void onTabTapped(int index) async {
    print(me.rewardAd);
    if (index == 2 && me.rewardAd < 1) {
      _showDialog(context);
    } else {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
    }
  }

  _showDialog(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Insufficient reward"),
            content: Text("View some ads to add reword in your account"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("View Ads"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewAdsPage()),
                  );
                },
              ),
            ],
          );
        });
  }

  Future<String> getToken() {
    return _fcm.getToken().then((value) => token = value);
  }

  Future<void> saveToken(String id) async {
    await getToken();
    print(token);
    await Firestore.instance
        .collection("deviceTokens")
        .document(id)
        .setData({"token": token, "userId": id}, merge: true);
  }

  Future initialise() async {
    await _fcm.subscribeToTopic('hello');
    _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          // await _showNotification(message);

          FlutterRingtonePlayer.play(
            android: AndroidSounds.notification,
            ios: IosSounds.glass,
            looping: true, // Android only - API >= 28
            volume: 0.8, // Android only - API >= 28
            asAlarm: false, // Android only - all APIs
          );
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");

          if (message['data'] != null && message['data']['type'] != null) {
            User msgUser = User(
                displayName: message['data']['displayName'],
                email: message['data']['email'],
                id: message['data']['id'],
                isActive: false,
                profilePicture: message['data']['profilePicture']);
            print(msgUser);

            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(friend: msgUser)));
          }
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");

          if (message['data'] != null && message['data']['type'] != null) {
            User msgUser = User(
                displayName: message['data']['displayName'],
                email: message['data']['email'],
                id: message['data']['id'],
                isActive: false,
                profilePicture: message['data']['profilePicture']);
            print(msgUser);

            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(friend: msgUser)));
          }
        },
        onBackgroundMessage: myBackgroundHandler);
  }

  Future _showNotification(Map<String, dynamic> message) async {
    print("this is from background msg $message");

    var attachmentPicturePath = await _downloadAndSaveFile(
        'https://via.placeholder.com/200x200', 'attachment_img.jpg');

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      '0',
      'channel name',
      'channel desc',
      importance: Importance.Max,
      priority: Priority.High,
      channelShowBadge: true,
      enableLights: true,
      largeIcon: FilePathAndroidBitmap(attachmentPicturePath),
    );

    var platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
      0,
      message['data']['displayName'] + " sent you a message.",
      message['data']['message'],
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
