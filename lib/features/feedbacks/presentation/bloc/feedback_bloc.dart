import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import '../../domain/repositories/feedback_repository.dart';
import 'feedback_event.dart';
import 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final SubmitFeedbackUseCase submitFeedbackUseCase;
  final FeedbackRepository repository;

  FeedbackBloc({
    required this.submitFeedbackUseCase,
    required this.repository,
  }) : super(FeedbackInitial()) {
    on<SubmitFeedbackRequested>(_onSubmitFeedbackRequested);
    on<LoadUserFeedbacksRequested>(_onLoadUserFeedbacksRequested);
  }

  Future<void> _onSubmitFeedbackRequested(SubmitFeedbackRequested event, Emitter<FeedbackState> emit) async {
    emit(FeedbackLoading());
    final result = await submitFeedbackUseCase(event.feedback);
    result.fold(
      (failure) => emit(FeedbackFailure(failure.message)),
      (_) => emit(FeedbackSuccess()),
    );
  }

  Future<void> _onLoadUserFeedbacksRequested(LoadUserFeedbacksRequested event, Emitter<FeedbackState> emit) async {
    emit(FeedbackLoading());
    final result = await repository.getUserFeedbacks(event.userId);
    result.fold(
      (failure) => emit(FeedbackFailure(failure.message)),
      (feedbacks) => emit(UserFeedbacksLoaded(feedbacks)),
    );
  }
}
