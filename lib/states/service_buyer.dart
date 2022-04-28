import 'package:flutter/material.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
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
    'สถานะสินค้า',
    'ประวัติราการสั่งซื้อ',
  ];

  var keyRoutes = <String>[
    MyConstant.routProfileBuyer,
    MyConstant.routShowShopForBuyer,
    '',
    MyConstant.routOrderHistoryBuyer,
  ];

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
