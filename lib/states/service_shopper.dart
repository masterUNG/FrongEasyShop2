import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/utility/my_process.dart';
import 'package:frongeasyshop/widgets/show_signout.dart';
import 'package:frongeasyshop/widgets/show_text.dart';

class ServiceShopper extends StatefulWidget {
  const ServiceShopper({Key? key}) : super(key: key);

  @override
  _ServiceShopperState createState() => _ServiceShopperState();
}

class _ServiceShopperState extends State<ServiceShopper> {
  List<String> titles = [
    'แก้ไขข้อมูลร้านค้า',
    'การสต๊อกสินค้า',
    'ประวัติรายการสั่งซื้อ',
    'สถานะคำสั่งซื้อ',
  ];

  List<String> routeProduct = [
    MyConstant.routEditShopProFile,
    MyConstant.routStockProduct,
    MyConstant.routOrderHistory,
    MyConstant.routOrderStatus,
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
    print('token seller ==> $token');
    await MyProcess().updateToken(docIdUser: user!.uid, token: token!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primart,
        title: const Text('ส่วนของร้านค้า'),
        actions: [ShowSignOut()],
      ),
      body: ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            if (routeProduct[index].isNotEmpty) {
              Navigator.pushNamed(context, routeProduct[index]);
            }
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
