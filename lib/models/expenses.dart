import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String category;
  double amount;
  DateTime date;
  String paymentMethod;
  String? description;
  Expense({
    this.id = '',
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'paymentMethod': paymentMethod,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, String documentId) {
    return Expense(
      id: documentId,
      category: map['category'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      date: (map['date'] as Timestamp).toDate(),
      paymentMethod: map['paymentMethod'] ?? '',
      description: map['description'],
    );
  }
}
