import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, TransactionEntity>> createTransaction(TransactionEntity transaction);
  Future<Either<Failure, List<TransactionEntity>>> getPatientTransactions(String phone);
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);
  Future<Either<Failure, TransactionEntity>> linkTransactionToUser(String transactionId, String userPhone);
}
