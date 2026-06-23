import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

abstract class PaymentRemoteDataSource {
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getPatientTransactions(String phone);
  Future<TransactionModel> getTransactionById(String id);
  Future<TransactionModel> linkTransactionToUser(String transactionId, String userPhone);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final FirebaseFirestore firestore;

  PaymentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final docRef = firestore.collection('transactions').doc();
    
    final transactionWithId = TransactionModel(
      id: docRef.id,
      patientName: transaction.patientName,
      patientPhone: transaction.patientPhone,
      payerPhone: transaction.payerPhone,
      serviceName: transaction.serviceName,
      amount: transaction.amount,
      createdAt: transaction.createdAt,
      cashierId: transaction.cashierId,
      status: transaction.status,
      qrCodeData: docRef.id, 
    );

    await docRef.set(transactionWithId.toMap());
    return transactionWithId;
  }

  @override
  Future<List<TransactionModel>> getPatientTransactions(String phone) async {
    final query = await firestore
        .collection('transactions')
        .where('patientPhone', isEqualTo: phone)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => TransactionModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    final doc = await firestore.collection('transactions').doc(id).get();
    if (!doc.exists) throw Exception('Transaction introuvable');
    return TransactionModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<TransactionModel> linkTransactionToUser(String transactionId, String userPhone) async {
    final docRef = firestore.collection('transactions').doc(transactionId);
    final doc = await docRef.get();
    
    if (!doc.exists) throw Exception('Transaction introuvable');
    
    await docRef.update({'patientPhone': userPhone});
    
    final updatedDoc = await docRef.get();
    return TransactionModel.fromMap(updatedDoc.data()!, updatedDoc.id);
  }
}
