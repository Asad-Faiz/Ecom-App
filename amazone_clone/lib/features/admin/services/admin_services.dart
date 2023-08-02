import 'dart:convert';
// import 'dart:developer';
import 'dart:io';

import 'package:amazone_clone/constants/error_handling.dart';
import 'package:amazone_clone/constants/utills.dart';
import 'package:amazone_clone/features/admin/model/sales.dart';
// import 'package:amazone_clone/features/account/widgets/orders.dart';
import 'package:amazone_clone/models/order.dart';
import 'package:amazone_clone/models/product.dart';
import 'package:amazone_clone/providers/user_provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../constants/global-variables.dart';

class AdminServices {
  static FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
// function to send notification
  initInfo(BuildContext context, int status, String deviceToken,
      String titleName, String prodImage) async {
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

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

    // what to show
    sendNotification(
        titleName,
        (status == 1)
            ? 'Order is Pending'
            : (status == 2)
                ? 'Prodct is Departured'
                : 'Product Recieved',
        deviceToken,
        prodImage);
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

  // ------------------------------------------------------------

  void sellProducts({
    required BuildContext context,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required List<File> images,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final cloudinary = CloudinaryPublic("ddyi6fgc3", "qixhs26o");
      List<String> imageUrls = [];
      for (int i = 0; i < images.length; i++) {
        CloudinaryResponse res = await cloudinary
            .uploadFile(CloudinaryFile.fromFile(images[i].path, folder: name));
        imageUrls.add(res.secureUrl);
      }
      Product product = Product(
          name: name,
          description: description,
          quantity: quantity,
          images: imageUrls,
          category: category,
          price: price);
      http.Response res = await http.post(
        Uri.parse('$uri/admin/add-product'),
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
      );
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () {
            showSnackBar(context, "product added succesfully");
            Navigator.pop(context);
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // updateProducts
  void UpdateProducts({
    required BuildContext context,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required String id,
    required List<String> images,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      Product product = Product(
          name: name,
          description: description,
          quantity: quantity,
          images: images,
          id: id,
          category: category,
          price: price);
      // log(product.toString());
      http.Response res = await http.post(
        Uri.parse('$uri/admin/update-product'),
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
      );
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () {
            showSnackBar(context, "product Updated succesfully");
            Navigator.pop(context);
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // gett all data from mongo db
  Future<List<Product>> fetchAllProducts(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];

    try {
      http.Response res =
          await http.get(Uri.parse("$uri/admin/get-products"), headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () {
            for (var i = 0; i < jsonDecode(res.body).length; i++) {
              productList.add(
                Product.fromJson(
                  jsonEncode(
                    jsonDecode(res.body)[i],
                  ),
                ),
              );
            }
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return productList;
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

  // get All Orders from the database
  Future<List<Order>> fetchAllOrders(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];

    try {
      http.Response res =
          await http.get(Uri.parse("$uri/admin/get-orders"), headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () {
            for (var i = 0; i < jsonDecode(res.body).length; i++) {
              orderList.add(
                Order.fromJson(
                  jsonEncode(
                    jsonDecode(res.body)[i],
                  ),
                ),
              );
            }
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return orderList;
  }

  //Change order status

  void changeOrderStatus(
      {required BuildContext context,
      required int status,
      required Order order,
      required VoidCallback onSucces}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/change-order-status'),
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': order.id, 'status': status}),
      );
      Map<String, dynamic> requestBody = jsonDecode(res.body);
      String deviceToken = requestBody['userToken'];
      String titleName = requestBody['order']['products'][0]['product']['name'];
      String prodImage =
          requestBody['order']['products'][0]['product']['images'][0];
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () async {
            onSucces();
            // http.Response res =
            //     await http.get(Uri.parse("$uri/admin/get-admin"), headers: {
            //   'Content-Type': 'application/json;charset=UTF-8',
            //   'x-auth-token': userProvider.user.token,
            // });
            // // Map<String, dynamic> requestBody = jsonDecode(res.body);
            // // String deviceToken = requestBody['deviceToken'];
            // // log(deviceToken);
            // log(res.body);
            initInfo(context, status, deviceToken, titleName, prodImage);
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // fetch Earnings
  Future<Map<String, dynamic>> getEarnings(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Sales> sales = [];
    int totalEarning = 0;

    try {
      http.Response res =
          await http.get(Uri.parse("$uri/admin/analytics"), headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });
      httpErrorHandele(
          response: res,
          context: context,
          onSuccess: () {
            var response = jsonDecode(res.body);
            totalEarning = response['totalEarnings'];
            sales = [
              Sales("Moibles", response['mobileEarnings']),
              Sales("Essentials", response['essentialEarnings']),
              Sales("Appliances", response['applianceEarnings']),
              Sales("Books", response['bookEarnings']),
              Sales("Fashion", response['fashionEarnings']),
            ];
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return {
      'sales': sales,
      'totalEarnings': totalEarning,
    };
  }
}
