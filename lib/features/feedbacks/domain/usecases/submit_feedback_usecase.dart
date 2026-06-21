import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feedback_entity.dart';
import '../repositories/feedback_repository.dart';

class SubmitFeedbackUseCase implements UseCase<void, FeedbackEntity> {
  final FeedbackRepository repository;

  SubmitFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(FeedbackEntity feedback) async {
    return await repository.submitFeedback(feedback);
  }
}
