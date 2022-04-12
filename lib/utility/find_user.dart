// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frongeasyshop/models/user_mdel.dart';

class FindUser {
  final String uid;
  FindUser({
    required this.uid,
  });

  Future<UserModel> findUserModel() async {
    var result =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();
    UserModel userModel = UserModel.fromMap(result.data()!);
    return userModel;
  }
}
