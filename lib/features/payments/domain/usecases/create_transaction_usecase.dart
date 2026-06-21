import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';

class CreateTransactionUseCase implements UseCase<TransactionEntity, TransactionEntity> {
  final PaymentRepository repository;

  CreateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(TransactionEntity transaction) async {
    return await repository.createTransaction(transaction);
  }
}
