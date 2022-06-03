// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/utility/my_process.dart';
import 'package:frongeasyshop/widgets/show_add_cart.dart';
import 'package:frongeasyshop/widgets/show_signout.dart';
import 'package:frongeasyshop/widgets/show_text.dart';

class ServiceBuyer extends StatefulWidget {
  const ServiceBuyer({Key? key}) : super(key: key);

  @override
  _ServiceBuyerState createState() => _ServiceBuyerState();
}

class _ServiceBuyerState extends State<ServiceBuyer> {
  var titles = <String>[
    'ข้อมูลส่วนตัว',
    'เลือกร้านค้า',
    'ประวัติราการสั่งซื้อ',
  ];

  var keyRoutes = <String>[
    MyConstant.routProfileBuyer,
    MyConstant.routShowShopForBuyer,
    MyConstant.routOrderHistoryBuyer,
  ];

  var user = FirebaseAuth.instance.currentUser;

  FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  InitializationSettings? initializationSettings;
  AndroidInitializationSettings? androidInitializationSettings;

  @override
  void initState() {
    super.initState();
    processMessaging();
    configLocalNotification();
  }

  Future<void> configLocalNotification() async {
    androidInitializationSettings =
        const AndroidInitializationSettings('app_icon');
    initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await flutterLocalNotificationPlugin.initialize(
      initializationSettings!,
      onSelectNotification: onSelectNoti,
    );
  }

  Future<void> onSelectNoti(String? string) async {
    if (string != null) {
      print(' onSelect Work');
    }
  }

  Future<void> processShowLocalNotification(
      {required String title, required String body}) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'channelId',
      'channelName',
      priority: Priority.high,
      importance: Importance.max,
      ticker: 'Noti',
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationPlugin.show(
        0, title, body, notificationDetails);
  }

  Future<void> processMessaging() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();
    print('token buyer ==> $token');
    await MyProcess().updateToken(docIdUser: user!.uid, token: token!);

    FirebaseMessaging.onMessage.listen((event) {
      String? title = event.notification!.title;
      String? body = event.notification!.body;
      processShowLocalNotification(title: title!, body: body!);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
       String? title = event.notification!.title;
      String? body = event.notification!.body;
      processShowLocalNotification(title: title!, body: body!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
         
          const ShowAddCart(),
          const ShowSignOut(),
        ],
        backgroundColor: MyConstant.primart,
        title: const Text('ส่วนของลูกค้า'),
      ),
      body: ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            if (keyRoutes[index].isNotEmpty) {
              Navigator.pushNamed(context, keyRoutes[index]);
            }
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShowText(
                title: titles[index],
                textStyle: MyConstant().h2Style(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
