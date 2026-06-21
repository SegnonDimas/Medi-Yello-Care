import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateTransactionUseCase createTransactionUseCase;
  final PaymentRepository repository;

  PaymentBloc({
    required this.createTransactionUseCase,
    required this.repository,
  }) : super(PaymentInitial()) {
    on<CreateTransactionRequested>(_onCreateTransactionRequested);
    on<LoadPatientTransactionsRequested>(_onLoadPatientTransactionsRequested);
  }

  Future<void> _onCreateTransactionRequested(CreateTransactionRequested event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    final result = await createTransactionUseCase(event.transaction);
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (transaction) => emit(TransactionCreated(transaction)),
    );
  }

  Future<void> _onLoadPatientTransactionsRequested(LoadPatientTransactionsRequested event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    final result = await repository.getPatientTransactions(event.phone);
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (transactions) => emit(PatientTransactionsLoaded(transactions)),
    );
  }
}
