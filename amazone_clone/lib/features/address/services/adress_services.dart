import 'dart:convert';
import 'dart:developer';
// import 'dart:io';

import 'package:amazone_clone/constants/error_handling.dart';
import 'package:amazone_clone/constants/utills.dart';
import 'package:amazone_clone/models/product.dart';
import 'package:amazone_clone/models/user.dart';
import 'package:amazone_clone/providers/user_provider.dart';
// import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../constants/global-variables.dart';

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

// init info function

// bafseukfgdb

class AddressServices {
  static FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
//
  initInfo(BuildContext context) async {
    // Local Notfication Setup
    const androidInitialize =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitialize,
    );

    plugin.initialize(initializationSettings, onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      log('${notificationResponse.payload}');

      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          log(notificationResponse.payload.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => const Scaffold(
                    body: Center(
                      child: Text('Taps'),
                    ),
                  )),
            ),
          );
          break;
        case NotificationResponseType.selectedNotificationAction:
          // print(notificationResponse);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => const Scaffold(
                    body: Center(
                      child: Text('Action'),
                    ),
                  )),
            ),
          );
          break;
      }
    });
    // firebase MEssage recieveing code
    FirebaseMessaging.onMessage.listen((event) async {
      print('-------------Message-------------');
      print('1 onMessage ${event.notification!.title}/${event.data}');
      // preparing to show notification on local device
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        event.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: event.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      final http.Response response = await http.get(
        Uri.parse(event.data['image']),
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'basic',
        'messages',
        importance: Importance.max,
        styleInformation: bigTextStyleInformation,
        priority: Priority.max,
        playSound: true,
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(
            base64Encode(response.bodyBytes)),
        actions: [
          const AndroidNotificationAction('1', 'Done',
              allowGeneratedReplies: true)
        ],
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails(),
      );
      await plugin.show(0, event.notification!.title, event.notification!.body,
          platformChannelSpecifics,
          payload: event.data['body ']);
    });
    sendNotification(
        'Hi ',
        'User Placed Order',
        'cmGlxtFrTQGAQ2l-e2yf6I:APA91bHnn0aIQAi37Si1fgBDqqMxtZd7_VnjI0yu5Z0TJfZaU_Z_AKUKLN6n_yGXidwLRmOuZnpURdq7hGbDYirAYiojqZKoPUDgSlYYmv_LcoWUNO4-a27MA8zzSFoUjZ9Fp_ypK8wA',
        'https://plus.unsplash.com/premium_photo-1668116307088-583ee0d4aaf7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDF8Ym84alFLVGFFMFl8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60');
  }

  // send Notification
  sendNotification(String title, String body, to, icon) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization":
              "key=AAAAfFium4Q:APA91bEcsKuXn0A34vV0L93Cwml8DTlk_pqhGtg37LGH99UZjMip0pUeP87_yBSIEONksoY8J-Slff0wo5Kgi6mH6VbcKyoph85ZyUjHjbDbH1f-ZfZWmTtMaq-OpD37XQ4SHX_BCP72",
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            "to": to,
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "basic",
              'image': icon,
            },
            "data": <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
              'image': icon,
              "url": icon,
            }
          },
        ),
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  // nmsdfbrjkbgerkjbgerkgberuigjbserkljbgsrjkbg vsrhjkfgn

  void saveUserAddress({
    required BuildContext context,
    required String address,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/save-user-address'),
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'address': address,
        }),
      );
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () {
            User user = userProvider.user.copyWith(
              address: jsonDecode(res.body)['address'],
            );
            userProvider.setUserFromModel(user);
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Place Order
  void placeOrder(
      {required BuildContext context,
      required String address,
      required String paymentMethod,
      required double totalSum}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // List<Product> productList = [];

    // try {
    http.Response res = await http.post(
      Uri.parse("$uri/api/order"),
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      },
      body: jsonEncode(
        {
          'cart': userProvider.user.cart,
          'address': address,
          'totalPrice': totalSum,
          'paymentMethod': paymentMethod,
        },
      ),
    );
    httpErrorHandele(
      response: res,
      context: context,
      onSuccess: () {
// noification wala code
        initInfo(context);

        showSnackBar(context, "Your Order Has been Placed!");
        User user = userProvider.user.copyWith(
          cart: [],
        );

        userProvider.setUserFromModel(user);
      },
    );
    // } catch (e) {
    //   showSnackBar(context, e.toString());
    // }
  }

//   to delete the product
  void deleteProduct(
      {required BuildContext context,
      required Product product,
      required VoidCallback onSucces}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/delete-products'),
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': product.id,
        }),
      );
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () {
            onSucces();
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
