// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/order_model.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/widgets/show_process.dart';
import 'package:frongeasyshop/widgets/show_text.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({Key? key}) : super(key: key);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  var user = FirebaseAuth.instance.currentUser;
  bool load = true;
  bool? haveData;
  var orderModels = <OrderModel>[];

  @override
  void initState() {
    super.initState();
    readOrder();
  }

  Future<void> readOrder() async {
    await FirebaseFirestore.instance
        .collection('order')
        .where('uidShopper', isEqualTo: user!.uid)
        .get()
        .then((value) {
      print('value ==> ${value.docs}');
      if (value.docs.isEmpty) {
        haveData = false;
      } else {
        haveData = true;
        for (var item in value.docs) {
          // print('item ===> ${item.data()}');

          var mapOrders = item.data()['mapOrders'];
          print('mapOrders ===> $mapOrders');

          // OrderModel orderModel = OrderModel.fromMap(item.data());
          // orderModels.add(orderModel);
        }
      }
      load = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primart,
        title: const Text('ประวัติรายการสั่งซื้อ'),
      ),
      body: load
          ? const ShowProcess()
          : haveData!
              ? ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) => ShowText(title: 'Order'),
                )
              : Center(
                  child: ShowText(
                    title: 'No Order',
                    textStyle: MyConstant().h1Style(),
                  ),
                ),
    );
  }
}
