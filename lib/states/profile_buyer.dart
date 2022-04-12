import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/user_mdel.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/widgets/show_process.dart';
import 'package:frongeasyshop/widgets/show_text.dart';

class ProfileBuyer extends StatefulWidget {
  const ProfileBuyer({Key? key}) : super(key: key);

  @override
  State<ProfileBuyer> createState() => _ProfileBuyerState();
}

class _ProfileBuyerState extends State<ProfileBuyer> {
  var user = FirebaseAuth.instance.currentUser;
  UserModel? userModel;
  bool load = true;

  @override
  void initState() {
    super.initState();
    readProfile();
  }

  Future<void> readProfile() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get()
        .then((value) {
      setState(() {
        load = false;
        userModel = UserModel.fromMap(value.data()!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primart,
        title: const Text('ข้อมูลส่วนตัว'),
      ),
      body: load
          ? const Center(child: ShowProcess())
          : Column(
            children: [
              newLabel(head: 'ชื่อ :', value: userModel!.name),
              newLabel(head: 'Email :', value: userModel!.email)
            ],
          ),
    );
  }

  Row newLabel({required String head, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ShowText(
          title: head,
          textStyle: MyConstant().h2Style(),
        ),
        ShowText(title: value),
      ],
    );
  }
}
