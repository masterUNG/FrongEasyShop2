// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/product_model.dart';
import 'package:frongeasyshop/models/profile_shop_model.dart';
import 'package:frongeasyshop/models/sqlite_model.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/utility/my_dialog.dart';
import 'package:frongeasyshop/utility/sqlite_helper.dart';
import 'package:frongeasyshop/widgets/show_image_from_url.dart';
import 'package:frongeasyshop/widgets/show_process.dart';
import 'package:frongeasyshop/widgets/show_text.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

class DisplayCart extends StatefulWidget {
  const DisplayCart({
    Key? key,
  }) : super(key: key);

  @override
  State<DisplayCart> createState() => _DisplayCartState();
}

class _DisplayCartState extends State<DisplayCart> {
  bool load = true;
  bool? haveData;
  var sqliteModels = <SQLiteModel>[];
  ProfileShopModel? profileShopModel;
  int total = 0;

  bool displayPromptPay = false;
  File? file;

  @override
  void initState() {
    super.initState();
    readSQLite();
  }

  Future<void> readSQLite() async {
    if (sqliteModels.isNotEmpty) {
      sqliteModels.clear();
      total = 0;
    }
    await SQLiteHelper().readAllData().then((value) async {
      print('value readSQLite ==> $value');

      if (value.isEmpty) {
        haveData = false;
      } else {
        haveData = true;

        for (var item in value) {
          SQLiteModel sqLiteModel = item;
          sqliteModels.add(sqLiteModel);
          total = total + int.parse(sqLiteModel.sum);
        }

        await FirebaseFirestore.instance
            .collection('user')
            .doc(sqliteModels[0].docUser)
            .collection('profile')
            .get()
            .then((value) {
          for (var item in value.docs) {
            setState(() {
              profileShopModel = ProfileShopModel.fromMap(item.data());
            });
          }
        });
      }

      setState(() {
        load = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primart,
        title: const Text('ตะกร้า'),
      ),
      body: load
          ? const ShowProcess()
          : haveData!
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShowText(
                          title: profileShopModel!.nameShop,
                          textStyle: MyConstant().h1Style(),
                        ),
                        ShowText(
                          title: profileShopModel!.address,
                          textStyle: MyConstant().h3Style(),
                        ),
                        showHead(),
                        listCart(),
                        const Divider(
                          color: Colors.blue,
                        ),
                        newTotal(),
                        newControlButton(),
                        displayPromptPay ? showPromptPay() : const SizedBox(),
                        file == null
                            ? const SizedBox()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 32),
                                        width: 250,
                                        height: 250,
                                        child: Image.file(file!),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: const Text(
                                              'Upload สลิปการจ่ายเงิน'))
                                    ],
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: ShowText(
                    title: 'ยังไม่มี สินค้าใน ตะกร้า',
                    textStyle: MyConstant().h2Style(),
                  ),
                ),
    );
  }

  Row showPromptPay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const SizedBox(
              width: 200,
              height: 200,
              child: ShowImageFromUrl(
                  path:
                      'https://www.androidthai.in.th/election/promptpay/promptpay.png'),
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      var response = await Dio().get(
                          "https://www.androidthai.in.th/election/promptpay/promptpay.png",
                          options: Options(responseType: ResponseType.bytes));
                      final result = await ImageGallerySaver.saveImage(
                          Uint8List.fromList(response.data),
                          quality: 60,
                          name: "promptpay");
                      print(result);
                      if (result['isSuccess']) {
                        print('success True');
                        MyDialog().normalDialog(context, 'Download Success',
                            'ไปเปิดแอพธนาคา และ Scan PromptPay พร้อม เก็บ Slip และ อัพโหลด Slip เพื่อยืนยันการจ่ายเงิน');
                      } else {
                        print('success False');
                      }
                    },
                    child: const Text('Download PromptPay')),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(
                  onPressed: () async {
                    var result = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        maxHeight: 800);
                    setState(() {
                      file = File(result!.path);
                    });
                  },
                  child: const Text('เลือกสลิปการจ่ายเงิน'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Row newControlButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () async {
            await SQLiteHelper().deleteAllData().then((value) => readSQLite());
          },
          child: const Text('เคลียร์ตะกร้า'),
        ),
        const SizedBox(
          width: 4,
        ),
        ElevatedButton(
            onPressed: () async {
              // ระบบตัด Stock และ Clear ตระกล้า

              // for (var item in sqliteModels) {
              //   await FirebaseFirestore.instance
              //       .collection('user')
              //       .doc(item.docUser)
              //       .collection('stock')
              //       .doc(item.docStock)
              //       .collection('product')
              //       .doc(item.docProduct)
              //       .get()
              //       .then((value) async {
              //     ProductModel productModel =
              //         ProductModel.fromMap(value.data()!);
              //     int newAmountProduct =
              //         productModel.amountProduct - int.parse(item.amount);

              //     Map<String, dynamic> data = {};
              //     data['amountProduct'] = newAmountProduct;

              //     await FirebaseFirestore.instance
              //         .collection('user')
              //         .doc(item.docUser)
              //         .collection('stock')
              //         .doc(item.docStock)
              //         .collection('product')
              //         .doc(item.docProduct)
              //         .update(data)
              //         .then((value) {
              //       print('Success Update ${item.nameProduct}');
              //     });
              //   });
              // }
              // await SQLiteHelper()
              //     .deleteAllData()
              //     .then((value) => readSQLite());

              displayPromptPay = true;

              setState(() {});
            },
            child: const Text('สั่งซื้อ')),
        const SizedBox(
          width: 4,
        ),
      ],
    );
  }

  Row newTotal() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ShowText(
                title: 'Total : ',
                textStyle: MyConstant().h3Style(),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: ShowText(
            title: '$total',
            textStyle: MyConstant().h3Style(),
          ),
        ),
      ],
    );
  }

  Container showHead() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ShowText(
              title: 'ชื่อสินค้า',
              textStyle: MyConstant().h3Style(),
            ),
          ),
          Expanded(
            flex: 1,
            child: ShowText(
              title: 'ราคา',
              textStyle: MyConstant().h3Style(),
            ),
          ),
          Expanded(
            flex: 1,
            child: ShowText(
              title: 'จำนวน',
              textStyle: MyConstant().h3Style(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ShowText(
                title: 'รวม',
                textStyle: MyConstant().h3Style(),
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }

  ListView listCart() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: sqliteModels.length,
      itemBuilder: (context, index) => Row(
        children: [
          Expanded(
            flex: 3,
            child: ShowText(title: sqliteModels[index].nameProduct),
          ),
          Expanded(
            flex: 1,
            child: Center(child: ShowText(title: sqliteModels[index].price)),
          ),
          Expanded(
            flex: 1,
            child: Center(child: ShowText(title: sqliteModels[index].amount)),
          ),
          Expanded(
            flex: 1,
            child: Center(child: ShowText(title: sqliteModels[index].sum)),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () async {
                await SQLiteHelper()
                    .deleteValueFromId(sqliteModels[index].id!)
                    .then((value) => readSQLite());
              },
              icon: const Icon(Icons.delete_forever),
            ),
          ),
        ],
      ),
    );
  }
}
