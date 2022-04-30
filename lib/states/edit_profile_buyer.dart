// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:frongeasyshop/models/user_mdel.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/widgets/show_form.dart';

class EditProfileBuyer extends StatefulWidget {
  final UserModel userModel;
  const EditProfileBuyer({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  State<EditProfileBuyer> createState() => _EditProfileBuyerState();
}

class _EditProfileBuyerState extends State<EditProfileBuyer> {
  String? name, address, phone;
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  UserModel? userModel;
  Map<String, dynamic> map = {};
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    userModel = widget.userModel;
    nameController.text = userModel!.name;
    addressController.text = userModel!.address!;
    phoneController.text = userModel!.phone!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไข ข้อมูล ผู้ซืือ'),
        backgroundColor: MyConstant.primart,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  ShowForm(
                      textEditingController: nameController,
                      title: 'ชื่อ :',
                      myValidate: nameValidate,
                      mySave: nameSave),
                  ShowForm(
                      textEditingController: addressController,
                      title: 'ที่อยู่ :',
                      myValidate: addressValidate,
                      mySave: addressSave),
                  ShowForm(
                      textEditingController: phoneController,
                      title: 'เบอร์โทรศัพย์ :',
                      myValidate: phoneValidate,
                      mySave: phoneSave),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        print('map ====>>> $map');

                        await FirebaseFirestore.instance
                            .collection('user')
                            .doc(user!.uid)
                            .update(map)
                            .then((value) => Navigator.pop(context));
                      }
                    },
                    child: const Text('แก้ไข'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void nameSave(String? string) {
    name = string!.trim();
    map['name'] = name;
  }

  String? nameValidate(String? string) {
    if (string!.isEmpty) {
      return 'กรุณากรอกชื่อ';
    } else {
      return null;
    }
  }

  void addressSave(String? string) {
    address = string!.trim();
    map['address'] = address;
  }

  String? addressValidate(String? string) {
    if (string!.isEmpty) {
      return 'กรุณากรอกที่อยู่';
    } else {
      return null;
    }
  }

  void phoneSave(String? string) {
    phone = string!.trim();
    map['phone'] = phone;
  }

  String? phoneValidate(String? string) {
    if (string!.isEmpty) {
      return 'กรุณากรอกเบอร์โทร';
    } else {
      return null;
    }
  }
}
