// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String email;
  final String name;
  final String password;
  final String typeuser;
  final String? address;
  final String? phone;
  final String? token;
  UserModel({
    required this.email,
    required this.name,
    required this.password,
    required this.typeuser,
    this.address,
    this.phone,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'password': password,
      'typeuser': typeuser,
      'address': address,
      'phone': phone,
      'token': token,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: (map['email'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      password: (map['password'] ?? '') as String,
      typeuser: (map['typeuser'] ?? '') as String,
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      token: map['token'] ?? '',
    );
  }

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
