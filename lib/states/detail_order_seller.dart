// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/order_model.dart';

import 'package:frongeasyshop/utility/my_constant.dart';
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

  @override
  void initState() {
    super.initState();
    docIdOrder = widget.docIdOrder;
    readOrder();
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
                newLabel(title: 'วันสั่งสินค้า :', subTitle: changeDateToString(orderModel!.dateOrder)),
              ],
            ),
    );
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
