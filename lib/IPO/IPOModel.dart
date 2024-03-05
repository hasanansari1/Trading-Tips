// IPOModel.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class IPOModel {
  final String id;
  final String stockName;
  final int lot;
  final double price;
  final String openingDate;
  final String closingDate;
  final String remark;
  final String status;

  IPOModel({
    required this.id,
    required this.stockName,
    required this.lot,
    required this.price,
    required this.openingDate,
    required this.closingDate,
    required this.remark,
    required this.status,
  });

  factory IPOModel.fromSnapshot(DocumentSnapshot snapshot) {
    // Handle different types for the 'price' field
    dynamic priceValue = snapshot['price'];
    double price;
    if (priceValue is num) {
      price = priceValue.toDouble();
    } else if (priceValue is String) {
      // Convert 'price' String to double (adjust the conversion logic if needed)
      price = double.parse(priceValue);
    } else {
      // Handle other cases or provide a default value
      price = 0.0; // You may want to adjust this default value based on your requirements
    }

    // Handle different types for the 'lot' field
    dynamic lotValue = snapshot['lot'];
    int lot;
    if (lotValue is int) {
      lot = lotValue;
    } else if (lotValue is String) {
      // Convert 'lot' String to int (adjust the conversion logic if needed)
      lot = int.tryParse(lotValue) ?? 0; // Use 0 as a default value if parsing fails
    } else {
      // Handle other cases or provide a default value
      lot = 0; // You may want to adjust this default value based on your requirements
    }

    return IPOModel(
      id: snapshot.id,
      stockName: snapshot['stockName'],
      lot: lot,
      price: price,
      openingDate: snapshot['openingDate'],
      closingDate: snapshot['closingDate'],
      remark: snapshot['remark'],
      status: snapshot['status'] ?? 'All',
    );
  }
}
