import 'package:equatable/equatable.dart';

enum TransactionStatus { pending, completed, cancelled }

class TransactionEntity extends Equatable {
  final String id;
  final String patientName;
  final String patientPhone;
  final String payerPhone;
  final String serviceName;
  final double amount;
  final DateTime createdAt;
  final String cashierId;
  final TransactionStatus status;
  final String? qrCodeData;

  const TransactionEntity({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.payerPhone,
    required this.serviceName,
    required this.amount,
    required this.createdAt,
    required this.cashierId,
    required this.status,
    this.qrCodeData,
  });

  @override
  List<Object?> get props => [
        id,
        patientName,
        patientPhone,
        payerPhone,
        serviceName,
        amount,
        createdAt,
        cashierId,
        status,
        qrCodeData,
      ];
}
