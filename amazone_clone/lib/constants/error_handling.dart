import 'dart:convert';

import 'package:amazone_clone/constants/utills.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> httpErrorHandele(
    {required http.Response response,
    required BuildContext context,
    required onSuccess}) async {
  switch (response.statusCode) {
    case 200:
      await onSuccess();
      break;
    case 400:
      showSnackBar(context, jsonDecode(response.body)["msg"]);
      break;
    case 500:
      showSnackBar(context, jsonDecode(response.body)["error"]);
      break;
    default:
      showSnackBar(context, response.body);
  }
}
