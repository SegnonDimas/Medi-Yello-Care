import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:get_it/get_it.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<PaymentBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Scanner le QR Code')),
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is TransactionFetched) {
              _showConfirmationDialog(context, state);
            } else if (state is TransactionLinkedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction associée avec succès !'), backgroundColor: AppColors.success),
              );
              Navigator.pop(context);
            } else if (state is PaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
              setState(() => _isScanning = true);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                if (_isScanning)
                  MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty && _isScanning) {
                        setState(() => _isScanning = false);
                        final String? code = barcodes.first.rawValue;
                        if (code != null) {
                          context.read<PaymentBloc>().add(ScanQrCodeRequested(code));
                        }
                      }
                    },
                  ),
                if (state is PaymentLoading)
                  const Center(child: CircularProgressIndicator()),
                _buildOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 4),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, TransactionFetched state) {
    final tx = state.transaction;
    final authState = GetIt.I<AuthBloc>().state;
    
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (innerContext) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Transaction trouvée', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Service : ${tx.serviceName}'),
            Text('Montant : ${tx.amount} FCFA'),
            Text('Date : ${tx.createdAt.toString()}'),
            const SizedBox(height: 24),
            const Text('Voulez-vous associer cette transaction à votre compte ?'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(innerContext);
                      setState(() => _isScanning = true);
                    },
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (authState is Authenticated) {
                        context.read<PaymentBloc>().add(
                          LinkTransactionRequested(
                            transactionId: tx.id,
                            userPhone: authState.user.phoneNumber,
                          ),
                        );
                        Navigator.pop(innerContext);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
