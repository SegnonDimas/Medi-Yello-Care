import 'package:equatable/equatable.dart';

enum FeedbackType { complaint, suggestion, appreciation }
enum FeedbackStatus { received, analyzing, resolved }

class FeedbackEntity extends Equatable {
  final String id;
  final String userId;
  final FeedbackType type;
  final String hospitalName;
  final String serviceName;
  final String description;
  final String? transactionId;
  final DateTime createdAt;
  final FeedbackStatus status;

  const FeedbackEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.hospitalName,
    required this.serviceName,
    required this.description,
    this.transactionId,
    required this.createdAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        hospitalName,
        serviceName,
        description,
        transactionId,
        createdAt,
        status,
      ];
}
