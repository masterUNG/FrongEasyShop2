import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/user_mdel.dart';
import 'package:frongeasyshop/states/edit_profile_buyer.dart';
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
        print('userModel buyer ==> ${userModel!.toMap()}');
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
      floatingActionButton: ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileBuyer(
                    userModel: userModel!,
                  ),
                )).then((value) {
              readProfile();
            });
          },
          child: const Text('Edit Profile')),
      body: load
          ? const Center(child: ShowProcess())
          : Column(
              children: [
                newLabel(head: 'ชื่อ :', value: userModel!.name),
                newLabel(head: 'Email :', value: userModel!.email),
                newLabel(head: 'ที่อยู่ :', value: userModel!.address!),
                newLabel(head: 'เบอร์โทร :', value: userModel!.phone!)
              ],
            ),
    );
  }

  Row newLabel({required String head, required String value}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ShowText(
            title: head,
            textStyle: MyConstant().h2Style(),
          ),
        ),
        Expanded(
          flex: 2,
          child: ShowText(title: value),
        ),
      ],
    );
  }
}
