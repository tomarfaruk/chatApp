import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findfriend/core/models/chatModel.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/core/services/adMobService.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:findfriend/core/services/recentUsersService.dart';
import 'package:findfriend/ui/widgets/recentUserWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentUsersScreen extends StatefulWidget {
  static const routeName = "/GeneralUserScreen";
  @override
  _RecentUsersScreenState createState() => _RecentUsersScreenState();
}

class _RecentUsersScreenState extends State<RecentUsersScreen> {
  ScrollController scrollController = ScrollController();

  List<DocumentSnapshot> documentList = List<DocumentSnapshot>();
  RecentUsersService recentUsersService = RecentUsersService();

  Fbauth auth;

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      print("at the end of list 11");

      recentUsersService.requestMoreUser(me);
    }
  }

  User me;
  @override
  void initState() {
    auth = Provider.of<Fbauth>(context, listen: false);
    me = auth.getMe;
    super.initState();

    scrollController.addListener(_scrollListener);
    // bannerSize = AdmobBannerSize.FULL_BANNER;
  }

  AdmobBannerSize bannerSize;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: recentUsersService.listenToUsersRealTime(me),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data.length == 0) {
          return Center(child: Text("no user found"));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Some error"));
        }

        return ListView(
          controller: scrollController,
          children: [
            // Container(
            //   color: Colors.black12,
            //   child: AdmobBanner(
            //     adUnitId: Ads.getBannerAdUnitId(),
            //     adSize: bannerSize,
            //     listener: (AdmobAdEvent event, Map<String, dynamic> args) {
            //       print(event.toString());
            //     },
            //   ),
            // ),
            ...snapshot.data.map((Chat d) => RecentUserWidget(chat: d)),
            // Text("${snapshot.data}"),
            // ...snapshot.data.map((d) => Text("${d.friend}")),
            SizedBox(height: 65),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
