import 'package:cloud_firestore/cloud_firestore.dart';

class IntraDayModel {
  final String id;
  final String category;
  final String status;
  final String stockName;
  final String cmp;
  final String target;
  final String sl;
  final String remark;
  final Timestamp date;

  IntraDayModel({
    required this.id,
    required this.category,
    required this.status,
    required this.stockName,
    required this.cmp,
    required this.target,
    required this.sl,
    required this.remark,
    required this.date,
  });

  factory IntraDayModel.fromSnapshot(DocumentSnapshot snapshot) {
    return IntraDayModel(
      id: snapshot.id,
      category: snapshot['category'],
      status: snapshot['status'],
      stockName: snapshot['stockName'],
      cmp: snapshot['cmp'],
      target: snapshot['target'],
      sl: snapshot['sl'],
      remark: snapshot['remark'],
      date: snapshot['date'] is Timestamp
          ? snapshot['date']  // If already a Timestamp, use it
          : Timestamp.fromDate(DateTime.parse(snapshot['date'])), // Convert from String to DateTime
    );
  }
}
