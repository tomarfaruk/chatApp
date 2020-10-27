import 'package:admob_flutter/admob_flutter.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/core/services/adMobService.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewAdsPage extends StatefulWidget {
  @override
  _ViewAdsPageState createState() => _ViewAdsPageState();
}

class _ViewAdsPageState extends State<ViewAdsPage> {
  User me;
  Fbauth auth;
  AdmobReward rewardAd;

  @override
  void initState() {
    super.initState();
    auth = Provider.of<Fbauth>(context, listen: false);

    me = auth.getMe;

    rewardAd = initAds();
  }

  initAds() {
    return AdmobReward(
      adUnitId: Ads.getRewardBasedVideoAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) async {
        if (event == AdmobAdEvent.closed) {
          rewardAd?.dispose();
          setState(() {});
          print("claose video 000000000000000000......... $event $args ");
        }
        if (event == AdmobAdEvent.rewarded) {
          me.rewardAd += 5;
          await auth.updateUserReward();

          print("reward video 00000000000000000........ $event $args ");
        }

        if (event == AdmobAdEvent.loaded) {
          rewardAd.show();
          print("load video 0000000000000000..... $event $args ");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("View ads and get reward")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Your current reward: ${me.rewardAd}"),
            SizedBox(height: 30),
            Center(
              child: RaisedButton(
                  elevation: 3,
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('View ads',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  onPressed: () async {
                    rewardAd.load();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
