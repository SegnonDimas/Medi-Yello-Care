import 'package:equatable/equatable.dart';
import '../../domain/entities/feedback_entity.dart';

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

class SubmitFeedbackRequested extends FeedbackEvent {
  final FeedbackEntity feedback;
  const SubmitFeedbackRequested(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

class LoadUserFeedbacksRequested extends FeedbackEvent {
  final String userId;
  const LoadUserFeedbacksRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
