import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';

class CashierHomePage extends StatefulWidget {
  const CashierHomePage({super.key});

  @override
  State<CashierHomePage> createState() => _CashierHomePageState();
}

class _CashierHomePageState extends State<CashierHomePage> {
  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _payerPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedService = 'Consultation Générale';
  final _formKey = GlobalKey<FormState>();

  final List<String> _services = [
    'Consultation Générale',
    'Analyses de Sang',
    'Radiographie',
    'Pharmacie',
    'Ophtalmologie',
    'Dentisterie',
  ];

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    _payerPhoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitPayment(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final transaction = TransactionEntity(
          id: '',
          patientName: _patientNameController.text.trim(),
          patientPhone: _patientPhoneController.text.trim(),
          payerPhone: _payerPhoneController.text.trim(),
          serviceName: _selectedService,
          amount: double.parse(_amountController.text.trim()),
          createdAt: DateTime.now(),
          cashierId: authState.user.uid,
          status: TransactionStatus.completed,
        );

        context.read<PaymentBloc>().add(CreateTransactionRequested(transaction));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PaymentBloc>(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Espace Caissier'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
                ),
              ],
            ),
            body: BlocListener<PaymentBloc, PaymentState>(
              listener: (context, state) {
                if (state is TransactionCreated) {
                  _showQrCodeDialog(state.transaction);
                  _formKey.currentState?.reset();
                } else if (state is PaymentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enregistrer un Paiement',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(_patientNameController, 'Nom du Patient', Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildTextField(_patientPhoneController, 'Téléphone du Patient', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField(_payerPhoneController, 'Numéro MTN MoMo (Payeur)', Icons.payment, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedService,
                        decoration: const InputDecoration(
                          labelText: 'Service',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                        items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (value) => setState(() => _selectedService = value!),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_amountController, 'Montant (FCFA)', Icons.money, keyboardType: TextInputType.number),
                      const SizedBox(height: 32),
                      BlocBuilder<PaymentBloc, PaymentState>(
                        builder: (context, state) {
                          if (state is PaymentLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return ElevatedButton(
                            onPressed: () => _submitPayment(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Valider Paiement MoMo'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      keyboardType: keyboardType,
      validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
    );
  }

  void _showQrCodeDialog(TransactionEntity transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paiement Validé', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text('Transaction ID: ${transaction.id}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              width: 200,
              child: QrImageView(
                data: transaction.qrCodeData ?? '',
                version: QrVersions.auto,
                foregroundColor: Theme.of(context).colorScheme.inverseSurface,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Veuillez scanner ce code pour les soins.', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }
}
