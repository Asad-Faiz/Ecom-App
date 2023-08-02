import 'dart:convert';
import 'dart:developer';
// import 'dart:io';

import 'package:amazone_clone/constants/error_handling.dart';
import 'package:amazone_clone/constants/global-variables.dart';
import 'package:amazone_clone/constants/utills.dart';
// import 'package:amazone_clone/models/product.dart';
// import 'package:amazone_clone/features/home/screens/home_screen.dart';
import 'package:amazone_clone/models/user.dart';
import 'package:amazone_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widgets/bottom-bar.dart';

class AuthService {
  void signUpUser(
      {required BuildContext context,
      required String email,
      required String password,
      required String name}) async {
    try {
      User user = User(
          id: "",
          name: name,
          email: email,
          password: password,
          address: "",
          type: " ",
          token: "",
          deviceToken: '',
          cart: []);
      // uri comming from globalvarirable
      log(user.toString());
      http.Response res = await http.post(Uri.parse('$uri/api/signup'),
          body: user.toJson(),
          headers: <String, String>{
            'Content-Type': 'application/json;charset=UTF-8'
          });
      // log(res.statusCode.toString());
// httpErrorHandle is a function created in error-handling.dart files
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () {
            showSnackBar(context, "Account has been created");
          });
    } catch (e) {
      log(e.toString());
      showSnackBar(context, e.toString());
    }
  }

  // sign up
  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
    required String deviceToken,
  }) async {
    try {
      http.Response res = await http.post(Uri.parse('$uri/api/signin'),
          body: jsonEncode({
            'email': email,
            'password': password,
            'deviceToken': deviceToken
          }),
          headers: <String, String>{
            'Content-Type': 'application/json;charset=UTF-8'
          });
      log(res.body);

// httpErrorHandle is a function created in error-handling.dart files
      // ignore: use_build_context_synchronously
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () async {
            // to store user ata in app memory
            SharedPreferences prefs = await SharedPreferences.getInstance();
            // created a user_provider now
            Provider.of<UserProvider>(context, listen: false).setUser(res.body);
            // we will give token as value
            await prefs.setString(
                "x-auth-token", jsonDecode(res.body)['token']);
          });
      Navigator.pushNamedAndRemoveUntil(
          context, BottomBar.routeName, (route) => false);
    } catch (e) {
      log(e.toString());
      showSnackBar(context, e.toString());
    }
  }

  // Get user data
  void getUserData({
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("x-auth-token");
      if (token == null) {
        prefs.setString("x-auth-token", "");
      }
      // to check if token is authentic or not
      var tokenRes = await http
          .post(Uri.parse('$uri/tokenIsValid'), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'x-auth-token': token!,
      });
      var response = jsonDecode(tokenRes.body);
      if (response == true) {
        // get user data
        http.Response userRes =
            await http.get(Uri.parse('$uri/'), headers: <String, String>{
          'Content-Type': 'application/json;charset=UTF-8',
          'x-auth-token': token,
        });
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      log(e.toString());
      showSnackBar(context, e.toString());
    }
  }
}
