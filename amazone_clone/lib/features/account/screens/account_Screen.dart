import 'package:amazone_clone/constants/global-variables.dart';
import 'package:amazone_clone/features/account/widgets/bellow_appbar.dart';
import 'package:amazone_clone/features/account/widgets/top_buttons.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: GlobalVariables.appBarGradient),
          ),
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/images/amazon_in.png',
                width: 120,
                height: 45,
                color: Colors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Icon(Icons.notifications_outlined),
                  ),
                  Icon(Icons.search),
                ],
              ),
            )
          ]),
        ),
      ),
      body: const Column(
        children: [
          // bellow_appbar.dart
          BellowAppBar(),
          SizedBox(
            height: 10,
          ),
          // top_button.dart
          TopButtons(),
        ],
      ),
    );
  }
}
