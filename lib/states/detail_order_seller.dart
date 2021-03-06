// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/order_model.dart';
import 'package:frongeasyshop/models/user_mdel.dart';

import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/utility/my_process.dart';
import 'package:frongeasyshop/widgets/show_button.dart';
import 'package:frongeasyshop/widgets/show_process.dart';
import 'package:frongeasyshop/widgets/show_text.dart';
import 'package:intl/intl.dart';

class DetailOrderSeller extends StatefulWidget {
  final String docIdOrder;
  const DetailOrderSeller({
    Key? key,
    required this.docIdOrder,
  }) : super(key: key);

  @override
  State<DetailOrderSeller> createState() => _DetailOrderSellerState();
}

class _DetailOrderSellerState extends State<DetailOrderSeller> {
  String? docIdOrder;
  bool load = true;
  OrderModel? orderModel;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    docIdOrder = widget.docIdOrder;
    readOrder();
  }

  Future<void> findDetailBuyer() async {
    await MyProcess().findUserModel(uid: orderModel!.uidBuyer).then((value) {
      setState(() {
        userModel = value;
      });
    });
  }

  Future<void> readOrder() async {
    await FirebaseFirestore.instance
        .collection('order')
        .doc(docIdOrder)
        .get()
        .then((value) {
      orderModel = OrderModel.fromMap(value.data()!);
      load = false;
      setState(() {});
      findDetailBuyer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียด บิลสั่งซื้อ'),
        backgroundColor: MyConstant.primart,
      ),
      body: load
          ? const ShowProcess()
          : Column(
              children: [
                newLabel(title: 'หมายเลขบิล :', subTitle: docIdOrder!),
                newLabel(
                    title: 'วันสั่งสินค้า :',
                    subTitle: changeDateToString(orderModel!.dateOrder)),
                newLabel(
                    title: 'วิธีรับสินค้า :',
                    subTitle: orderModel!.typeTransfer),
                newLabel(
                    title: 'วิธีชำระสินค้า :',
                    subTitle: orderModel!.typePayment),
                newLabel(title: 'สถาณะ :', subTitle: orderModel!.status),
                newLabel(
                    title: 'ที่อยู่จัดส่ง :',
                    subTitle: userModel == null ? '' : userModel!.address!),
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
                orderModel!.status == 'order'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              ShowButton(
                                label: 'Receive Order',
                                pressFunc: () {
                                  processTakeOrder(status: 'receive');
                                },
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              ShowButton(
                                label: 'Cancel Order',
                                pressFunc: () {
                                  processTakeOrder(status: 'cancel');
                                },
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox()
              ],
            ),
    );
  }

  Future<void> processTakeOrder({required String status}) async {
    UserModel userModel =
        await MyProcess().findUserModel(uid: orderModel!.uidBuyer);
    await MyProcess().sentNotification(
        title: '$status รายการสั่งซื่อ',
        body: 'ทางร้าน ได้ $status รายการสั่งซื่อของคุณลูกค้า',
        token: userModel.token!);
    Map<String, dynamic> map = {};
    map['status'] = status;
    await FirebaseFirestore.instance
        .collection('order')
        .doc(docIdOrder)
        .update(map)
        .then((value) {
      Navigator.pop(context);
    });
  }

  Row newLabel({required String title, required String subTitle}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ShowText(
            title: title,
            textStyle: MyConstant().h2Style(),
          ),
        ),
        Expanded(flex: 1,
          child: ShowText(title: subTitle),
        ),
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
