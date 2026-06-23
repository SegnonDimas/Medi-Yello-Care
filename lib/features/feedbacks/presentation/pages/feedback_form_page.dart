import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/feedback_bloc.dart';
import '../bloc/feedback_event.dart';
import '../bloc/feedback_state.dart';
import '../../domain/entities/feedback_entity.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:get_it/get_it.dart';
import 'feedback_success_page.dart';

class FeedbackFormPage extends StatefulWidget {
  final String? transactionId;
  final String? serviceName;

  const FeedbackFormPage({super.key, this.transactionId, this.serviceName});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _hospitalController = TextEditingController(text: 'Centre Médical Medi Y\'ello');
  final _serviceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FeedbackType _selectedType = FeedbackType.complaint;

  @override
  void initState() {
    super.initState();
    if (widget.serviceName != null) {
      _serviceController.text = widget.serviceName!;
    }
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _serviceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final feedback = FeedbackEntity(
          id: '',
          userId: authState.user.uid,
          type: _selectedType,
          hospitalName: _hospitalController.text.trim(),
          serviceName: _serviceController.text.trim(),
          description: _descriptionController.text.trim(),
          transactionId: widget.transactionId,
          createdAt: DateTime.now(),
          status: FeedbackStatus.received,
        );
        
        context.read<FeedbackBloc>().add(SubmitFeedbackRequested(feedback));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.I<FeedbackBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Donner un avis')),
        body: BlocConsumer<FeedbackBloc, FeedbackState>(
          listener: (context, state) {
            if (state is FeedbackSuccess) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const FeedbackSuccessPage()),
              );
            } else if (state is FeedbackFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is FeedbackLoading;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.transactionId != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Cet avis est lié à votre transaction ${widget.transactionId}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text('De quoi s\'agit-il ?', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<FeedbackType>(
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(value: FeedbackType.complaint, child: Text('Plainte')),
                        DropdownMenuItem(value: FeedbackType.suggestion, child: Text('Suggestion')),
                        DropdownMenuItem(value: FeedbackType.appreciation, child: Text('Remerciement')),
                      ],
                      onChanged: isLoading ? null : (v) => setState(() => _selectedType = v!),
                      decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hospitalController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(labelText: 'Établissement', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                      validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(labelText: 'Service concerné', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                      validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !isLoading,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Détails de votre message',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Veuillez décrire votre avis' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      child: isLoading 
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                              SizedBox(width: 12),
                              Text('Envoi en cours...'),
                            ],
                          )
                        : const Text('Envoyer mon avis'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
