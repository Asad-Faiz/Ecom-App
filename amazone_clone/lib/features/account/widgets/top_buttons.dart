import 'package:amazone_clone/features/account/services/acount_services.dart';
import 'package:amazone_clone/features/account/widgets/account_button.dart';
import 'package:amazone_clone/features/account/widgets/orders.dart';
import 'package:flutter/material.dart';

class TopButtons extends StatelessWidget {
  const TopButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AccountButton(text: "your Orders", onTap: () {}),
            AccountButton(text: "turn Sellers", onTap: () {}),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            AccountButton(
                text: "Log out",
                onTap: () {
                  AcountServices().logOut(context);
                }),
            AccountButton(text: "Your WishList", onTap: () {}),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Orders(),
      ],
    );
  }
}
