import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/feedback_entity.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasources/feedback_remote_data_source.dart';
import '../models/feedback_model.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;

  FeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> submitFeedback(FeedbackEntity feedback) async {
    try {
      final model = FeedbackModel.fromEntity(feedback);
      await remoteDataSource.submitFeedback(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedbackEntity>>> getUserFeedbacks(String userId) async {
    try {
      final result = await remoteDataSource.getUserFeedbacks(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
