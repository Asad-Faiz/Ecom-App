// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class BannerAdds extends StatefulWidget {
//   const BannerAdds({super.key});

//   @override
//   State<BannerAdds> createState() => _BannerAddsState();
// }

// class _BannerAddsState extends State<BannerAdds> {
//   late BannerAd _bannerAd;
//   bool _isLoaded = false;
//   final String rewardedAdUnitId = "ca-app-pub-3287616909265784/4626609018";
//   @override
//   void initState() {
//     super.initState();
//     _initBannerAd();
//   }

//   void _initBannerAd() {
//     _bannerAd = BannerAd(
//       size: AdSize.banner,
//       adUnitId: rewardedAdUnitId,
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() {
//             _isLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (ad, error) {},
//       ),
//       request: AdRequest(),
//     );
//     _bannerAd.load();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       child: _isLoaded
//           ? Container(
//               height: _bannerAd.size.height.toDouble(),
//               width: _bannerAd.size.height.toDouble(),
//               child: AdWidget(ad: _bannerAd),
//             )
//           : SizedBox(
//               child: Text(_isLoaded.toString()),
//             ),
//     );
//   }
// }
import 'package:amazone_clone/features/home/service/Admob_services.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdd extends StatefulWidget {
  const BannerAdd({super.key});

  @override
  State<BannerAdd> createState() => _BannerAddState();
}

class _BannerAddState extends State<BannerAdd> {
  BannerAd? _bannerAd;
  bool isAdLoaded = false;
  @override
  void initState() {
    super.initState();
    initBannerAd();
  }

  initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdMobServices.bannerAdUnitId!,
      listener: AdMobServices.bannerAdListener,
      request: const AdRequest(),
    )..load();
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdMobServices.bannerAdUnitId!,
      listener: AdMobServices.bannerAdListener,
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bannerAd == null
          ? Container()
          : Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(
                ad: _bannerAd!,
              )),
    );
  }
}
