import 'package:admob_flutter/admob_flutter.dart';

class Ads {
  static bool rewarded = false;
  AdmobBannerSize bannerSize;

  static init() {
    Admob.initialize(getAppId());
  }

  static String getAppId() {
    return 'type your appid ';
  }

  static String getBannerAdUnitId() {
    return ' type tour banner id';
  }

  static String getInterstitialAdUnitId() {
    return 'type your add is';
  }

  static String getRewardBasedVideoAdUnitId() {
    return 'type your reward ad id';
  }
}
