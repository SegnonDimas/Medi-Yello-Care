import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/payments/data/datasources/payment_remote_data_source.dart';
import 'features/payments/data/repositories/payment_repository_impl.dart';
import 'features/payments/domain/repositories/payment_repository.dart';
import 'features/payments/domain/usecases/create_transaction_usecase.dart';
import 'features/payments/presentation/bloc/payment_bloc.dart';
import 'features/feedbacks/data/datasources/feedback_remote_data_source.dart';
import 'features/feedbacks/data/repositories/feedback_repository_impl.dart';
import 'features/feedbacks/domain/repositories/feedback_repository.dart';
import 'features/feedbacks/domain/usecases/submit_feedback_usecase.dart';
import 'features/feedbacks/presentation/bloc/feedback_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  sl.registerLazySingleton(() => AuthBloc(
        repository: sl(),
        signInUseCase: sl(),
        signUpUseCase: sl(),
      ));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()));

  // Features - Payments
  sl.registerFactory(() => PaymentBloc(
        createTransactionUseCase: sl(),
        repository: sl(),
      ));
  sl.registerLazySingleton(() => CreateTransactionUseCase(sl()));
  sl.registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<PaymentRemoteDataSource>(() => PaymentRemoteDataSourceImpl(firestore: sl()));

  // Features - Feedbacks
  sl.registerFactory(() => FeedbackBloc(
        submitFeedbackUseCase: sl(),
        repository: sl(),
      ));
  sl.registerLazySingleton(() => SubmitFeedbackUseCase(sl()));
  sl.registerLazySingleton<FeedbackRepository>(() => FeedbackRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<FeedbackRemoteDataSource>(() => FeedbackRemoteDataSourceImpl(firestore: sl()));

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
