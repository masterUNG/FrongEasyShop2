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
    return {
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
      mapOrders: (map['mapOrders']),
      status: map['status'] ?? '',
      totalOrder: map['totalOrder'] ?? '',
      typePayment: map['typePayment'] ?? '',
      typeTransfer: map['typeTransfer'] ?? '',
      uidBuyer: map['uidBuyer'] ?? '',
      uidShopper: map['uidShopper'] ?? '',
      urlSlip: map['urlSlip'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) => OrderModel.fromMap(json.decode(source));
}
