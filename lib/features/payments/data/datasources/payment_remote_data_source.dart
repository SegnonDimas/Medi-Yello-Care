import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

abstract class PaymentRemoteDataSource {
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getPatientTransactions(String phone);
  Future<TransactionModel> getTransactionById(String id);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final FirebaseFirestore firestore;

  PaymentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final docRef = firestore.collection('transactions').doc();
    
    // Simuler la génération du QR Code data (ici l'ID de la transaction suffit pour le hackathon)
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
    if (!doc.exists) throw Exception('Transaction not found');
    return TransactionModel.fromMap(doc.data()!, doc.id);
  }
}
