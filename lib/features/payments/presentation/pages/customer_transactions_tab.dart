import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/theme/app_colors.dart';
import 'transaction_detail_page.dart';
import 'qr_scanner_page.dart';

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
      child: Scaffold(
        body: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PatientTransactionsLoaded) {
              if (state.transactions.isEmpty) {
                return _buildEmptyState();
              }
              
              final groupedTransactions = _groupTransactionsByDate(state.transactions);
              final dates = groupedTransactions.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final transactions = groupedTransactions[date]!;
                  return _buildDailySummaryCard(context, date, transactions);
                },
              );
            } else if (state is PaymentError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Initialisant...'));
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
      ),
    );
  }

  Map<DateTime, List<TransactionEntity>> _groupTransactionsByDate(List<TransactionEntity> transactions) {
    final Map<DateTime, List<TransactionEntity>> grouped = {};
    for (var tx in transactions) {
      final dateOnly = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(tx);
    }
    return grouped;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Aucun paiement trouvé.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, DateTime date, List<TransactionEntity> transactions) {
    final theme = Theme.of(context);
    final total = transactions.fold(0.0, (sum, item) => sum + item.amount);
    final dateStr = DateFormat('dd MMMM yyyy', 'fr_FR').format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => GetIt.I<PaymentBloc>(),
                child: TransactionDetailPage(date: date, transactions: transactions),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 16),
              ...transactions.take(2).map((tx) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${tx.serviceName}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
                ),
              )),
              if (transactions.length > 2)
                Text(
                  'et ${transactions.length - 2} autres...',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dépense totale', style: TextStyle(color: Colors.grey)),
                  Text(
                    '${total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]} ")} FCFA',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

