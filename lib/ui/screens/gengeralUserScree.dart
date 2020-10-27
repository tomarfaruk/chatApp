import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/core/services/adMobService.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:findfriend/core/services/firestore.dart';
import 'package:findfriend/ui/widgets/userWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeneralUserScreen extends StatefulWidget {
  static const routeName = "/GeneralUserScreen";
  @override
  _GeneralUserScreenState createState() => _GeneralUserScreenState();
}

class _GeneralUserScreenState extends State<GeneralUserScreen> {
  ScrollController scrollController = ScrollController();

  List<DocumentSnapshot> documentList = List<DocumentSnapshot>();
  FirestoreService firestoreService = FirestoreService();

  Fbauth auth;

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      print("at the end of list 11");

      firestoreService.requestMoreUser();
    }
  }

  User me;
  @override
  void initState() {
    auth = Provider.of<Fbauth>(context, listen: false);
    me = auth.getMe;
    super.initState();

    scrollController.addListener(_scrollListener);
    bannerSize = AdmobBannerSize.FULL_BANNER;
  }

  AdmobBannerSize bannerSize;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestoreService.listenToUserRealTime(),
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
            Container(
              color: Colors.black12,
              child: AdmobBanner(
                adUnitId: Ads.getBannerAdUnitId(),
                adSize: bannerSize,
                listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                  print(event.toString());
                },
              ),
            ),
            ...snapshot.data.map((d) => UserWidget(friend: d)),
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
