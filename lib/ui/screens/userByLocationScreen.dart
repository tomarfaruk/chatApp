import 'package:admob_flutter/admob_flutter.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:findfriend/core/services/findUserByLocationProvider.dart';
import 'package:findfriend/ui/widgets/userWidget.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class UserByLocationScreen extends StatefulWidget {
  static const routeName = "/UserByLocationScreen";
  @override
  _UserByLocationScreenState createState() => _UserByLocationScreenState();
}

class _UserByLocationScreenState extends State<UserByLocationScreen> {
  FindUserByLocationProvider findUserByLocationProvider;

  LocationData _locationData;

  bool locationEnable = false;
  Fbauth auth;

  List<User> userList = List<User>();

  User me;

  @override
  void initState() {
    super.initState();

    auth = Provider.of<Fbauth>(context, listen: false);
    findUserByLocationProvider =
        Provider.of<FindUserByLocationProvider>(context, listen: false);
    me = auth.getMe;
    // bannerSize = AdmobBannerSize.FULL_BANNER;

    initData();
  }

  initData() async {
    _locationData = await findUserByLocationProvider.getLocation(me);
    locationEnable = true;
    if (mounted) {
      setState(() {});
    }
  }

  AdmobBannerSize bannerSize;

  @override
  Widget build(BuildContext context) {
    return locationEnable && _locationData != null
        ? StreamBuilder(
            stream:
                findUserByLocationProvider.listenToUserRealTime(_locationData),
            builder: (context, snapshot) {
              print("............... ${snapshot.data}");
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
                children: [
                  // Container(
                  //   color: Colors.black12,
                  //   child: AdmobBanner(
                  //     adUnitId: Ads.getBannerAdUnitId(),
                  //     adSize: bannerSize,
                  //     listener:
                  //         (AdmobAdEvent event, Map<String, dynamic> args) {
                  //       print(event.toString());
                  //       print(args);
                  //     },
                  //   ),
                  // ),

                  ...snapshot.data.map((d) => UserWidget(friend: d)),
                  SizedBox(height: 65),
                ],
              );
            })
        : locationEnable && _locationData == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Please device Enable GPS'),
                  SizedBox(height: 20),
                  InkWell(child: Icon(Icons.pin_drop), onTap: initData)
                ],
              )
            : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    super.dispose();
    // rewardAd?.dispose();
  }
}
