import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

abstract class FeedbackRemoteDataSource {
  Future<void> submitFeedback(FeedbackModel feedback);
  Future<List<FeedbackModel>> getUserFeedbacks(String userId);
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final FirebaseFirestore firestore;

  FeedbackRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> submitFeedback(FeedbackModel feedback) async {
    await firestore.collection('feedbacks').add(feedback.toMap());
  }

  @override
  Future<List<FeedbackModel>> getUserFeedbacks(String userId) async {
    final query = await firestore
        .collection('feedbacks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => FeedbackModel.fromMap(doc.data(), doc.id)).toList();
  }
}
