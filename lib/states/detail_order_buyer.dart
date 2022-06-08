// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/utility/my_process.dart';
import 'package:intl/intl.dart';

import 'package:frongeasyshop/models/order_model.dart';
import 'package:frongeasyshop/models/user_mdel.dart';
import 'package:frongeasyshop/utility/find_user.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/widgets/show_button.dart';
import 'package:frongeasyshop/widgets/show_text.dart';

class DetailOrderBuyer extends StatefulWidget {
  final OrderModel orderModel;
  final String docIdOrder;
  const DetailOrderBuyer({
    Key? key,
    required this.orderModel,
    required this.docIdOrder,
  }) : super(key: key);

  @override
  State<DetailOrderBuyer> createState() => _DetailOrderBuyerState();
}

class _DetailOrderBuyerState extends State<DetailOrderBuyer> {
  OrderModel? orderModel;
  String? nameShop;

  @override
  void initState() {
    super.initState();
    orderModel = widget.orderModel;
    findNameShop();
  }

  Future<void> findNameShop() async {
    UserModel userModel =
        await FindUser(uid: orderModel!.uidShopper).findUserModel();
    setState(() {
      nameShop = userModel.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primart,
        title: const Text('รายละเอียดการสั่งซื่อสินค้า'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            newLabel(
              title: 'ร้านสั่ง :',
              subTitle: nameShop ?? '',
            ),
            newLabel(
                title: 'วันสั่งของ :',
                subTitle: changeDateToString(orderModel!.dateOrder)),
            newLabel(
                title: 'วิธีการรับสินค้า :',
                subTitle: orderModel!.typeTransfer),
            newLabel(
                title: 'วิธีการชำระสินค้า :',
                subTitle: orderModel!.typePayment),
            newLabel(title: 'สถาณะ :', subTitle: orderModel!.status),
            Divider(
              color: MyConstant.dark,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ShowText(title: 'รายการ'),
                ),
                Expanded(
                  flex: 1,
                  child: ShowText(title: 'ราคา'),
                ),
                Expanded(
                  flex: 1,
                  child: ShowText(title: 'จำนวน'),
                ),
                Expanded(
                  flex: 1,
                  child: ShowText(title: 'รวม'),
                ),
              ],
            ),
            Divider(
              color: MyConstant.dark,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: orderModel!.mapOrders.length,
              itemBuilder: (context, index) => Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ShowText(
                      title: orderModel!.mapOrders[index]['nameProduct'],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ShowText(
                      title: orderModel!.mapOrders[index]['price'],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ShowText(
                      title: orderModel!.mapOrders[index]['amount'],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ShowText(
                      title: orderModel!.mapOrders[index]['sum'],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: MyConstant.dark,
            ),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShowText(
                        title: 'ผลรวมทั้งหมด :   ',
                        textStyle: MyConstant().h2Style(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ShowText(
                    title: orderModel!.totalOrder,
                    textStyle: MyConstant().h2Style(),
                  ),
                ),
              ],
            ),
            orderModel!.status == 'receive'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShowButton(
                        label: 'รับสินค้า',
                        pressFunc: () {
                          processReceiveProduct();
                        },
                      ),
                    ],
                  )
                : const SizedBox(),
            orderModel!.status == 'order'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShowButton(
                        label: 'Cancel Order',
                        pressFunc: () {
                          processCancelOrder();
                        },
                      ),
                    ],
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Future<void> processReceiveProduct() async {
    Map<String, dynamic> map = {};
    map['status'] = 'finish';
    await FirebaseFirestore.instance
        .collection('order')
        .doc(widget.docIdOrder)
        .update(map)
        .then((value) async {
      UserModel userModel =
          await MyProcess().findUserModel(uid: orderModel!.uidShopper);
      await MyProcess()
          .sentNotification(
              title: 'ได้รับสินค้าแล้ว',
              body: 'ลูกค้าได้รับ สินค้าแล้ว',
              token: userModel.token!)
          .then((value) {
        Navigator.pop(context);
      });
    });
  }

  Future<void> processCancelOrder() async {
    Map<String, dynamic> map = {};
    map['status'] = 'cancel';
    await FirebaseFirestore.instance
        .collection('order')
        .doc(widget.docIdOrder)
        .update(map)
        .then((value) async {
      UserModel userModel =
          await MyProcess().findUserModel(uid: orderModel!.uidShopper);
      await MyProcess()
          .sentNotification(
              title: 'Cancel Order',
              body: 'ลูกค้าได้ Cancel สินค้าแล้ว',
              token: userModel.token!)
          .then((value) {
        Navigator.pop(context);
      });
    });
  }

  Row newLabel({required String title, required String subTitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShowText(
          title: title,
          textStyle: MyConstant().h2Style(),
        ),
        ShowText(title: subTitle),
      ],
    );
  }

  String changeDateToString(Timestamp timestamp) {
    DateFormat dateFormat = DateFormat('dd MMM yyyy');
    DateTime dateTime = timestamp.toDate();
    String string = dateFormat.format(dateTime);
    return string;
  }
}
