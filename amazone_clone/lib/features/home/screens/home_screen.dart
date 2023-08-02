import 'dart:developer';

import 'package:amazone_clone/common/widgets/custom_button.dart';
import 'package:amazone_clone/features/home/widgets/ads.dart';
import 'package:amazone_clone/features/home/widgets/bannerads.dart';
import 'package:amazone_clone/features/home/widgets/top_categories.dart';
import 'package:amazone_clone/features/search/screens/search__screen.dart';
import 'package:flutter/material.dart';
import '../../../constants/global-variables.dart';
import '../widgets/address_box.dart';
import '../widgets/carousel_image.dart';
import '../widgets/deal_of_day.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // speech to text instance
  SpeechToText speechToText = SpeechToText();
  // navigate to search screen function
  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  var hint = "Search Amazone";
  var isListening = false;
  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<UserProvider>(context).user;
    // log(user.deviceToken);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: GlobalVariables.appBarGradient),
          ),
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Container(
                height: 42,
                margin: const EdgeInsets.only(left: 15),
                child: Material(
                  borderRadius: BorderRadius.circular(7),
                  elevation: 1,
                  child: TextFormField(
                    onFieldSubmitted: (value) {
                      navigateToSearchScreen(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon: InkWell(
                        onTap: () {},
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 23,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.only(top: 10),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide.none),
                      enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide:
                              BorderSide(color: Colors.black38, width: 1)),
                      hintText: hint,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // for mic icon
            GestureDetector(
              onTapDown: (details) async {
                if (!isListening) {
                  var available = await speechToText.initialize();
                  if (available) {
                    setState(() {
                      isListening = true;
                      speechToText.listen(
                        onResult: (result) {
                          setState(() {
                            hint = result.recognizedWords;
                          });
                          if (hint != "Search Amazone") {
                            navigateToSearchScreen(hint);
                          }
                        },
                      );
                    });
                  }
                }
              },
              onTapUp: (details) {
                setState(() {
                  isListening = false;
                });
                speechToText.stop();
                log(hint);
              },
              child: Container(
                color: Colors.transparent,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.black, size: 25),
              ),
            )
          ]),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // import from address_box.dart
            AddressBox(),
            // categories list
            SizedBox(
              height: 10,
            ),
            // import from top_categories.dart
            TopCategories(),

            SizedBox(
              height: 10,
            ),
            // slider mages are Crousal images that swipe
            CarouselImage(),

            // deal_of_day.dart
            DealOfDay(),
            // GoogleAds(),
            // BannerAdd(),
            CustomButton(
                text: "go to Add",
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BannerAdd()));
                })
          ],
        ),
      ),
      // bottomNavigationBar: Container(),
    );
  }
}
