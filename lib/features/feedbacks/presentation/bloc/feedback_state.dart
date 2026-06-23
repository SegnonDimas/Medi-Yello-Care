import 'package:equatable/equatable.dart';
import '../../domain/entities/feedback_entity.dart';

abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackSuccess extends FeedbackState {}

class UserFeedbacksLoaded extends FeedbackState {
  final List<FeedbackEntity> feedbacks;
  const UserFeedbacksLoaded(this.feedbacks);

  @override
  List<Object?> get props => [feedbacks];
}

class FeedbackFailure extends FeedbackState {
  final String message;
  const FeedbackFailure(this.message);

  @override
  List<Object?> get props => [message];
}
