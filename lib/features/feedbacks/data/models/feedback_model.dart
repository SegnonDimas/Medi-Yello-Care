import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/feedback_entity.dart';

class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.hospitalName,
    required super.serviceName,
    required super.description,
    super.transactionId,
    required super.createdAt,
    required super.status,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String docId) {
    return FeedbackModel(
      id: docId,
      userId: map['userId'] ?? '',
      type: FeedbackType.values.firstWhere((e) => e.name == map['type'], orElse: () => FeedbackType.suggestion),
      hospitalName: map['hospitalName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      description: map['description'] ?? '',
      transactionId: map['transactionId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: FeedbackStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => FeedbackStatus.received),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'hospitalName': hospitalName,
      'serviceName': serviceName,
      'description': description,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
    };
  }

  factory FeedbackModel.fromEntity(FeedbackEntity entity) {
    return FeedbackModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      hospitalName: entity.hospitalName,
      serviceName: entity.serviceName,
      description: entity.description,
      transactionId: entity.transactionId,
      createdAt: entity.createdAt,
      status: entity.status,
    );
  }
}
