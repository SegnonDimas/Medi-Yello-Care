import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:medi_yellocare/features/payments/domain/entities/transaction_entity.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../feedbacks/presentation/pages/feedback_form_page.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class TransactionDetailPage extends StatefulWidget {
  final DateTime date;
  final List<TransactionEntity> transactions;

  const TransactionDetailPage({
    super.key,
    required this.date,
    required this.transactions,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final FlutterTts flutterTts = FlutterTts();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _speak() async {
    if (_isPlaying) {
      await flutterTts.stop();
      setState(() => _isPlaying = false);
      return;
    }

    double total = widget.transactions.fold(0, (sum, item) => sum + item.amount);
    String dateStr = DateFormat('dd MMMM yyyy', 'fr_FR').format(widget.date);
    
    String text = "Récapitulatif de vos soins du $dateStr. ";
    for (var tx in widget.transactions) {
      text += "${tx.serviceName}, ${tx.amount.toInt()} francs CFA. ";
    }
    text += "Le montant total est de ${total.toInt()} francs CFA.";

    setState(() => _isPlaying = true);
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd MMMM yyyy', 'fr_FR').format(widget.date);
    final total = widget.transactions.fold(0.0, (sum, item) => sum + item.amount);

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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Ticket de Soins'),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<PaymentBloc, PaymentState>(
  builder: (context, state) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Actes Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTES',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.blueGrey[300],
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.transactions.map((tx) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      //padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: GestureDetector(
                        onTap: () => _showTransactionDetails(context, tx),
                        child: ListTile(

                         title:  Text(
                           tx.serviceName,
                           style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                         ),
                         subtitle:  Text(
                            tx.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]} "),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          trailing: Text('Voir détails'),

                      ),),
                    ),
                  )),
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.blueGrey[600]),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]} ")} ',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF001F3F),
                              ),
                            ),
                            TextSpan(
                              text: 'FCFA',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE082), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD48806),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Paiement effectué',
                    style: TextStyle(
                      color: Color(0xFFD48806),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Audio Recap Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: _speak,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF001F3F),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.stop : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.speaker_group_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Écouter en Fon',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Image.asset(
                        'assets/images/waveform.png', // Fallback to a simple container if not exists
                        width: 100,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    '0:18',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QR Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    'QR DU TICKET',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.blueGrey[300],
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  QrImageView(
                    data: widget.transactions.first.id, // Grouped QR could use the first ID or a special hash
                    version: QrVersions.auto,
                    size: 180.0,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Présentez ce code à chaque étape de votre parcours de soins.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
  },
),
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
