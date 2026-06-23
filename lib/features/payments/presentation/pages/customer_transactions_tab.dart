import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_yellocare/features/payments/presentation/pages/qr_scanner_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:get_it/get_it.dart';
import '../../../feedbacks/presentation/pages/feedback_form_page.dart';

class CustomerTransactionsTab extends StatelessWidget {
  const CustomerTransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state;
        final bloc = GetIt.I<PaymentBloc>();
        if (authState is Authenticated) {
          bloc.add(LoadPatientTransactionsRequested(authState.user.phoneNumber));
        }
        return bloc;
      },
      child: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PatientTransactionsLoaded) {
            if (state.transactions.isEmpty) {
              return const Center(child: Text('Aucun paiement trouvé pour ce numéro.'));
            }
            return Scaffold(
              body: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  final tx = state.transactions[index];
                  return _buildTransactionCard(context, tx);
                },
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QrScannerPage()),
                  );
                },
                label: const Text('Scanner un QR', style: TextStyle(color: Colors.white)),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                backgroundColor: AppColors.primary,
              ),
            );
          } else if (state is PaymentError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Initialisant...'));
        },
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionEntity tx) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shadowColor: AppColors.secondary,
      child: ListTile(
        title: Text(tx.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montant: ${tx.amount} FCFA'),
            Text('Date: $dateStr'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.secondary, size: 16),
                const SizedBox(width: 4),
                Text('Payé via MoMo (${tx.payerPhone})', style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.qr_code, color: AppColors.primary),
        onTap: () => _showTransactionDetails(context, tx),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionEntity tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height*0.8,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('Récapitulatif de Soins', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              QrImageView(
                data: tx.qrCodeData ?? '',
                version: QrVersions.auto,
                foregroundColor: Theme.of(context).colorScheme.inverseSurface,
                size: 180.0,
              ),
              const SizedBox(height: 16),
              Text(tx.id, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 32),
              _detailRow('Patient', tx.patientName),
              _detailRow('Téléphone Patient', tx.patientPhone),
              _detailRow('Service', tx.serviceName),
              _detailRow('Montant', '${tx.amount} FCFA'),
              _detailRow('Statut', 'Paiement Confirmé', valueColor: AppColors.success),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Fermer le bottom sheet
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FeedbackFormPage(
                        transactionId: tx.id,
                        serviceName: tx.serviceName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review_outlined, color: Colors.white,),
                label: const Text('Donner mon avis', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}
