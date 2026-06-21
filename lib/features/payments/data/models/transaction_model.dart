import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.patientName,
    required super.patientPhone,
    required super.payerPhone,
    required super.serviceName,
    required super.amount,
    required super.createdAt,
    required super.cashierId,
    required super.status,
    super.qrCodeData,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      patientName: map['patientName'] ?? '',
      patientPhone: map['patientPhone'] ?? '',
      payerPhone: map['payerPhone'] ?? '',
      serviceName: map['serviceName'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      cashierId: map['cashierId'] ?? '',
      status: _statusFromString(map['status']),
      qrCodeData: map['qrCodeData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'patientPhone': patientPhone,
      'payerPhone': payerPhone,
      'serviceName': serviceName,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'cashierId': cashierId,
      'status': status.name,
      'qrCodeData': qrCodeData,
    };
  }

  static TransactionStatus _statusFromString(String? status) {
    switch (status) {
      case 'completed': return TransactionStatus.completed;
      case 'cancelled': return TransactionStatus.cancelled;
      default: return TransactionStatus.pending;
    }
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      patientName: entity.patientName,
      patientPhone: entity.patientPhone,
      payerPhone: entity.payerPhone,
      serviceName: entity.serviceName,
      amount: entity.amount,
      createdAt: entity.createdAt,
      cashierId: entity.cashierId,
      status: entity.status,
      qrCodeData: entity.qrCodeData,
    );
  }
}
