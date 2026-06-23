import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/feedback_bloc.dart';
import '../bloc/feedback_event.dart';
import '../bloc/feedback_state.dart';
import '../../domain/entities/feedback_entity.dart';
import 'feedback_form_page.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:get_it/get_it.dart';

class FeedbackTab extends StatelessWidget {
  const FeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state;
        final bloc = GetIt.I<FeedbackBloc>();
        if (authState is Authenticated) {
          bloc.add(LoadUserFeedbacksRequested(authState.user.uid));
        }
        return bloc;
      },
      child: Scaffold(
        body: BlocBuilder<FeedbackBloc, FeedbackState>(
          builder: (context, state) {
            if (state is FeedbackLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserFeedbacksLoaded) {
              if (state.feedbacks.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.feedbacks.length,
                itemBuilder: (context, index) => _buildFeedbackCard(context, state.feedbacks[index]),
              );
            } else if (state is FeedbackFailure) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Initialisant...'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openFeedbackForm(context),
          label:  Text('Nouvelle plainte / suggestion', style: TextStyle(color: Colors.white)),
          icon:  Icon(Icons.add_comment_outlined, color: Colors.white,),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feedback_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Vous n\'avez pas encore envoyé d\'avis.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, FeedbackEntity feedback) {
    final dateStr = DateFormat('dd/MM/yyyy').format(feedback.createdAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildTypeIcon(feedback.type),
        title: Text(feedback.serviceName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feedback.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                _buildStatusChip(feedback.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.complaint:
        return CircleAvatar(
          backgroundColor: Colors.red.shade400,
          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
        );
      case FeedbackType.suggestion:
        return CircleAvatar(
          backgroundColor: Colors.blue.shade400,
          child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
        );
      case FeedbackType.appreciation:
        return CircleAvatar(
          backgroundColor: Colors.green.shade400,
          child: const Icon(Icons.thumb_up_outlined, color: Colors.white, size: 20),
        );
    }
  }

  Widget _buildStatusChip(FeedbackStatus status) {
    String text = '';
    Color color = Colors.grey;
    switch (status) {
      case FeedbackStatus.received:
        text = 'Reçu';
        color = Colors.grey;
        break;
      case FeedbackStatus.analyzing:
        text = 'En analyse';
        color = AppColors.warning;
        break;
      case FeedbackStatus.resolved:
        text = 'Traité';
        color = AppColors.success;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _openFeedbackForm(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackFormPage()));
  }
}
