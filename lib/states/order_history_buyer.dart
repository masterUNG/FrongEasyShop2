// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/order_model.dart';
import 'package:frongeasyshop/models/user_mdel.dart';
import 'package:frongeasyshop/states/detail_order_buyer.dart';
import 'package:frongeasyshop/utility/find_user.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/widgets/show_process.dart';
import 'package:frongeasyshop/widgets/show_text.dart';
import 'package:intl/intl.dart';

class OrderHistoryBuyer extends StatefulWidget {
  const OrderHistoryBuyer({Key? key}) : super(key: key);

  @override
  _OrderHistoryBuyerState createState() => _OrderHistoryBuyerState();
}

class _OrderHistoryBuyerState extends State<OrderHistoryBuyer> {
  var user = FirebaseAuth.instance.currentUser;
  bool load = true;
  bool? haveData;
  var orderModels = <OrderModel>[];
  var userModelsBuyer = <UserModel>[];

  @override
  void initState() {
    super.initState();
    readOrder();
  }

  Future<void> readOrder() async {
    await FirebaseFirestore.instance
        .collection('order')
        .where('uidBuyer', isEqualTo: user!.uid)
        // .orderBy('dateOrder')
        .get()
        .then((value) async {
      print('value ==> ${value.docs}');
      if (value.docs.isEmpty) {
        haveData = false;
      } else {
        haveData = true;
        for (var item in value.docs) {
          print('item ===> ${item.data()}');

          var results = item.data()['mapOrders'];
          var mapOrders = <Map<String, dynamic>>[];
          for (var item in results) {
            mapOrders.add(item);
          }

          OrderModel orderModel = OrderModel(
              dateOrder: item.data()['dateOrder'],
              mapOrders: mapOrders,
              status: item.data()['status'],
              totalOrder: item.data()['totalOrder'],
              typePayment: item.data()['typePayment'],
              typeTransfer: item.data()['typeTransfer'],
              uidBuyer: item.data()['uidBuyer'],
              uidShopper: item.data()['uidShopper'],
              urlSlip: item.data()['urlSlip']);

          print('orderModel ===> ${orderModel.toMap()}');

          UserModel userModel =
              await FindUser(uid: orderModel.uidShopper).findUserModel();
          print('userModel ===>> ${userModel.toMap()}');
          userModelsBuyer.add(userModel);

          orderModels.add(orderModel);
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
                  itemCount: orderModels.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailOrderBuyer(orderModel: orderModels[index]),
                        )),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            newLabel(
                              title: 'ร้านสั่ง :',
                              subTitle: userModelsBuyer[index].name,
                            ),
                            newLabel(
                                title: 'วันสั่งของ :',
                                subTitle: changeDateToString(
                                    orderModels[index].dateOrder)),
                            newLabel(
                                title: 'วิธีการรับสินค้า :',
                                subTitle: orderModels[index].typeTransfer),
                            newLabel(
                                title: 'วิธีการชำระสินค้า :',
                                subTitle: orderModels[index].typePayment),
                            newLabel(
                                title: 'สถาณะ :',
                                subTitle: orderModels[index].status),
                            newLabel(
                                title: 'Total :',
                                subTitle: orderModels[index].totalOrder),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: ShowText(
                    title: 'No Order',
                    textStyle: MyConstant().h1Style(),
                  ),
                ),
    );
  }

  String changeDateToString(Timestamp timestamp) {
    DateFormat dateFormat = DateFormat('dd MMM yyyy');
    DateTime dateTime = timestamp.toDate();
    String string = dateFormat.format(dateTime);
    return string;
  }

  Row newLabel({required String title, required String subTitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShowText(title: title),
        ShowText(title: subTitle),
      ],
    );
  }
}
