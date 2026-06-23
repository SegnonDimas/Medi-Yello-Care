import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreateTransactionRequested extends PaymentEvent {
  final TransactionEntity transaction;
  const CreateTransactionRequested(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class LoadPatientTransactionsRequested extends PaymentEvent {
  final String phone;
  const LoadPatientTransactionsRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}

class ScanQrCodeRequested extends PaymentEvent {
  final String transactionId;
  const ScanQrCodeRequested(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class LinkTransactionRequested extends PaymentEvent {
  final String transactionId;
  final String userPhone;
  const LinkTransactionRequested({required this.transactionId, required this.userPhone});

  @override
  List<Object?> get props => [transactionId, userPhone];
}
