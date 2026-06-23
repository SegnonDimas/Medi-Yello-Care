import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class TransactionCreated extends PaymentState {
  final TransactionEntity transaction;
  const TransactionCreated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class PatientTransactionsLoaded extends PaymentState {
  final List<TransactionEntity> transactions;
  const PatientTransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionFetched extends PaymentState {
  final TransactionEntity transaction;
  const TransactionFetched(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionLinkedSuccess extends PaymentState {
  final TransactionEntity transaction;
  const TransactionLinkedSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
