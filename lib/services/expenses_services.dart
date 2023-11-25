import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prova_2/models/expenses.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> addExpense(Expense expense) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add(expense.toMap());
    }
  }

  Stream<List<Expense>> getExpenses() {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Expense.fromMap(doc.data(), doc.id))
              .toList());
    } else {
      return Stream.empty();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null && expense.id.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toMap());
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(expenseId)
          .delete();
    }
  }
}
