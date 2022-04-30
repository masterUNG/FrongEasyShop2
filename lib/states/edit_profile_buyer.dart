import 'package:flutter/material.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/widgets/show_form.dart';

class EditProfileBuyer extends StatefulWidget {
  const EditProfileBuyer({Key? key}) : super(key: key);

  @override
  State<EditProfileBuyer> createState() => _EditProfileBuyerState();
}

class _EditProfileBuyerState extends State<EditProfileBuyer> {
  String? name, address, phone;
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primart,
      ),
      body: Center(
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
            ElevatedButton(onPressed: () {}, child: const Text('แก้ไข'))
          ],
        ),
      ),
    );
  }

  void nameSave(String? string) {
    name = string!.trim();
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
  }

  String? phoneValidate(String? string) {
    if (string!.isEmpty) {
      return 'กรุณากรอกเบอร์โทร';
    } else {
      return null;
    }
  }
}
