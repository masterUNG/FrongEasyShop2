import 'package:flutter/material.dart';
import 'package:frongeasyshop/utility/my_constant.dart';

class ProfileBuyer extends StatelessWidget {
  const ProfileBuyer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: MyConstant.primart,
        title: const Text('ข้อมูลส่วนตัว'),
      ),
    );
  }
}
