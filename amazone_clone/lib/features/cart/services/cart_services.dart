import 'dart:convert';

import 'package:amazone_clone/constants/error_handling.dart';
import 'package:amazone_clone/constants/global-variables.dart';
import 'package:amazone_clone/constants/utills.dart';
import 'package:amazone_clone/models/product.dart';
import 'package:amazone_clone/models/user.dart';
import 'package:amazone_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CartServices {
// cart
  void RemoveFromCart({
    required BuildContext context,
    required Product product,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      // print((product.id!));

      http.Response res = await http.delete(
        Uri.parse('$uri/api/remove-from-cart/${product.id}'),
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      print(jsonDecode(res.body));
      httpErrorHandele(
        response: res,
        context: context,
        onSuccess: () {
          User user = userProvider.user.copyWith(
            cart: jsonDecode(res.body)['cart'],
          );
          userProvider.setUserFromModel(user);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
