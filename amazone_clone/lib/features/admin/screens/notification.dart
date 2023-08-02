import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  static const String routeName = '/notificationscreen';

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _counter = 0;
  String token = '';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void initState() {
    requestPermission();
    getToken();
    initInfo();
    super.initState();
  }

  // request Permission
  requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("Provisional");
    } else {
      print("Failed!!");
    }
  }

  // get Token Function
  getToken() async {
    await FirebaseMessaging.instance.getToken().then((value) async {
      log(value!);
      token = value;
      setState(() {});
    });
  }

  onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    // for ios
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    body: Text('Second Screen'),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  // init info function
  initInfo() async {
    // Local Notfication Setup
    const androidInitialize =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    var iOSIntialize = DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSIntialize);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
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
          print(notificationResponse);
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
      await flutterLocalNotificationsPlugin.show(0, event.notification!.title,
          event.notification!.body, platformChannelSpecifics,
          payload: event.data['body ']);
    });
  }

// send notification
  sendNotification(String title, body, to, icon) async {
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

// increament counter
  _incrementCounter() {
    setState(() {
      _counter++;
    });
    sendNotification(
        'Hi ',
        'increment : $_counter',
        'cmGlxtFrTQGAQ2l-e2yf6I:APA91bHnn0aIQAi37Si1fgBDqqMxtZd7_VnjI0yu5Z0TJfZaU_Z_AKUKLN6n_yGXidwLRmOuZnpURdq7hGbDYirAYiojqZKoPUDgSlYYmv_LcoWUNO4-a27MA8zzSFoUjZ9Fp_ypK8wA',
        'https://plus.unsplash.com/premium_photo-1668116307088-583ee0d4aaf7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDF8Ym84alFLVGFFMFl8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Send Notification"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'This Device Token:',
            ),
            Text(
              token,
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
