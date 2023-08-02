import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobServices {
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3287616909265784/4626609018';
    } else {
      return null;
    }
  }

  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3287616909265784/1675914565';
    } else {
      return null;
    }
  }

  static String? get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3287616909265784/6985448546';
    } else {
      return null;
    }
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: ((ad) => print('ad loaded')),
    onAdFailedToLoad: ((ad, error) {
      ad.dispose();
      print('error $error');
    }),
    onAdOpened: (ad) => print('ad open'),
    onAdClosed: (ad) => print('ad close'),
  );
}
