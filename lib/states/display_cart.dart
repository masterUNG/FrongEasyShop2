// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/order_model.dart';
import 'package:frongeasyshop/models/product_model.dart';
import 'package:frongeasyshop/models/profile_shop_model.dart';
import 'package:frongeasyshop/models/sqlite_model.dart';
import 'package:frongeasyshop/models/user_mdel.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/utility/my_dialog.dart';
import 'package:frongeasyshop/utility/my_process.dart';
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

  bool displayConfirmOrder = false;
  File? file;
  String? uidBuyer;
  String typeTransfer = 'onShop';
  String typePayment = 'promptPay';

  String urlSlip = '';

  @override
  void initState() {
    super.initState();
    readSQLite();
    findUidBuyer();
  }

  Future<void> findUidBuyer() async {
    await FirebaseAuth.instance.authStateChanges().listen((event) {
      uidBuyer = event!.uid;
    });
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
        title: const Text('??????????????????'),
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
                        displayConfirmOrder
                            ? newTypeTransfer()
                            : const SizedBox(),
                        displayConfirmOrder
                            ? newTypePayment()
                            : const SizedBox(),
                        (displayConfirmOrder && (typePayment == 'promptPay'))
                            ? showPromptPay()
                            : displayConfirmOrder
                                ? ElevatedButton(
                                    onPressed: () => processSaveOrder(),
                                    child: const Text('???????????????????????????????????????????????????'),
                                  )
                                : const SizedBox(),
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
                                          onPressed: () async {
                                            String nameSlip =
                                                '$uidBuyer${Random().nextInt(1000)}.jpg';
                                            FirebaseStorage firebaseStorage =
                                                FirebaseStorage.instance;
                                            Reference reference =
                                                firebaseStorage
                                                    .ref()
                                                    .child('slip/$nameSlip');
                                            UploadTask uploadTask =
                                                reference.putFile(file!);
                                            await uploadTask
                                                .whenComplete(() async {
                                              await reference
                                                  .getDownloadURL()
                                                  .then((value) async {
                                                urlSlip = value.toString();
                                                print('urlSlip ==> $urlSlip');
                                                processSaveOrder();
                                              });
                                            });
                                          },
                                          child: const Text(
                                              '????????????????????? ????????????????????????????????????????????? ???????????????????????????????????????????????????'))
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
                    title: '???????????????????????? ???????????????????????? ??????????????????',
                    textStyle: MyConstant().h2Style(),
                  ),
                ),
    );
  }

  Column newTypeTransfer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowText(
          title: '?????????????????????????????????????????????????????????',
          textStyle: MyConstant().h2Style(),
        ),
        RadioListTile(
          title: const ShowText(title: '??????????????????????????????'),
          value: 'onShop',
          groupValue: typeTransfer,
          onChanged: (value) {
            setState(() {
              typeTransfer = value.toString();
            });
          },
        ),
        RadioListTile(
          title: const ShowText(title: '????????????????????????????????????'),
          value: 'delivery',
          groupValue: typeTransfer,
          onChanged: (value) {
            setState(() {
              typeTransfer = value.toString();
            });
          },
        ),
      ],
    );
  }

  Column newTypePayment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowText(
          title: '??????????????????????????????????????????????????????',
          textStyle: MyConstant().h2Style(),
        ),
        RadioListTile(
          title: const ShowText(title: '???????????????????????????'),
          value: 'promptPay',
          groupValue: typePayment,
          onChanged: (value) {
            setState(() {
              typePayment = value.toString();
            });
          },
        ),
        RadioListTile(
          title: const ShowText(title: '?????????????????????????????????????????????'),
          value: 'cashDelivery',
          groupValue: typePayment,
          onChanged: (value) {
            setState(() {
              typePayment = value.toString();
            });
          },
        ),
      ],
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
                        MyDialog().normalDialog(
                          context,
                          'Download Success',
                          '?????????????????????????????????????????? ????????? Scan PromptPay ??????????????? ???????????? Slip ????????? ????????????????????? Slip ??????????????????????????????????????????????????????????????????',
                        );
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
                  child: const Text('????????????????????????????????????????????????????????????'),
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
          child: const Text('???????????????????????????????????????'),
        ),
        const SizedBox(
          width: 4,
        ),
        ElevatedButton(
            onPressed: () {
              displayConfirmOrder = true;
              setState(() {});
            },
            child: const Text('????????????????????????')),
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
              title: '??????????????????????????????',
              textStyle: MyConstant().h3Style(),
            ),
          ),
          Expanded(
            flex: 1,
            child: ShowText(
              title: '????????????',
              textStyle: MyConstant().h3Style(),
            ),
          ),
          Expanded(
            flex: 1,
            child: ShowText(
              title: '???????????????',
              textStyle: MyConstant().h3Style(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ShowText(
                title: '?????????',
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

  Future<void> processSaveOrder() async {
    var mapOrders = <Map<String, dynamic>>[];
    for (var item in sqliteModels) {
      mapOrders.add(item.toMap());
    }

    Timestamp dateOrder = Timestamp.fromDate(DateTime.now());

    OrderModel orderModel = OrderModel(
        dateOrder: dateOrder,
        mapOrders: mapOrders,
        status: 'order',
        totalOrder: total.toString(),
        typePayment: typePayment,
        typeTransfer: typeTransfer,
        uidBuyer: uidBuyer!,
        uidShopper: sqliteModels[0].docUser,
        urlSlip: urlSlip);

    DocumentReference reference =
        FirebaseFirestore.instance.collection('order').doc();

    await reference.set(orderModel.toMap()).then((value) async {
      String docId = reference.id;
      print('## Save Order Success $docId');

      // ????????????????????? Stock ????????? Clear ?????????????????????

      for (var item in sqliteModels) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(item.docUser)
            .collection('stock')
            .doc(item.docStock)
            .collection('product')
            .doc(item.docProduct)
            .get()
            .then((value) async {
          ProductModel productModel = ProductModel.fromMap(value.data()!);
          int newAmountProduct =
              productModel.amountProduct - int.parse(item.amount);

          Map<String, dynamic> data = {};
          data['amountProduct'] = newAmountProduct;

          await FirebaseFirestore.instance
              .collection('user')
              .doc(item.docUser)
              .collection('stock')
              .doc(item.docStock)
              .collection('product')
              .doc(item.docProduct)
              .update(data)
              .then((value) {
            print('Success Update ${item.nameProduct}');
          });
        });
      }
      await SQLiteHelper().deleteAllData().then((value) async {
        UserModel userModel =
            await MyProcess().findUserModel(uid: orderModel.uidShopper);

        await MyProcess()
            .sentNotification(
                title: '??????????????????????????????????????????????????????',
                body: '????????????????????????????????????????????????????????????????????? ????????? ??????????????????????????????',
                token: userModel.token!)
            .then((value) {
          // readSQLite();
          Navigator.pushNamedAndRemoveUntil(
              context, MyConstant.routServiceBuyer, (route) => false);
        });
      });
    });
  }
}
