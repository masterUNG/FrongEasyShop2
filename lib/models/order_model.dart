// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final Timestamp dateOrder;
  final List<Map<String, dynamic>> mapOrders;
  final String status;
  final String totalOrder;
  final String typePayment;
  final String typeTransfer;
  final String uidBuyer;
  final String uidShopper;
  final String urlSlip;
  OrderModel({
    required this.dateOrder,
    required this.mapOrders,
    required this.status,
    required this.totalOrder,
    required this.typePayment,
    required this.typeTransfer,
    required this.uidBuyer,
    required this.uidShopper,
    required this.urlSlip,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dateOrder': dateOrder,
      'mapOrders': mapOrders,
      'status': status,
      'totalOrder': totalOrder,
      'typePayment': typePayment,
      'typeTransfer': typeTransfer,
      'uidBuyer': uidBuyer,
      'uidShopper': uidShopper,
      'urlSlip': urlSlip,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      dateOrder: (map['dateOrder']),
      mapOrders: List<Map<String, dynamic>>.from(map['mapOrders']),
      status: (map['status'] ?? '') as String,
      totalOrder: (map['totalOrder'] ?? '') as String,
      typePayment: (map['typePayment'] ?? '') as String,
      typeTransfer: (map['typeTransfer'] ?? '') as String,
      uidBuyer: (map['uidBuyer'] ?? '') as String,
      uidShopper: (map['uidShopper'] ?? '') as String,
      urlSlip: (map['urlSlip'] ?? '') as String,
    );
  }

  factory OrderModel.fromJson(String source) => OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
