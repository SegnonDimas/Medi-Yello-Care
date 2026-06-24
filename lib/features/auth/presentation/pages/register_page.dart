import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Veuillez entrer votre nom' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty ?? true ? 'Veuillez entrer votre numéro' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'NPI',
                      prefixIcon: Icon(Icons.card_membership),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value?.isEmpty ?? true ? 'Veuillez entrer votre email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                      if (value.length < 6) return 'Le mot de passe doit faire au moins 6 caractères';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Je suis un :', style: theme.textTheme.titleMedium),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<UserRole>(
                          title: const Text('Patient'),
                          value: UserRole.customer,
                          groupValue: _selectedRole,
                          onChanged: (value) => setState(() => _selectedRole = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<UserRole>(
                          title: const Text('Caissier'),
                          value: UserRole.cashier,
                          groupValue: _selectedRole,
                          onChanged: (value) => setState(() => _selectedRole = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final user = UserEntity(
                              uid: '', // Firestore set id
                              fullName: _fullNameController.text.trim(),
                              email: !(_emailController.text.contains("@"))?"${_emailController.text.trim()}@gmail.com" : _emailController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              role: _selectedRole,
                            );
                            context.read<AuthBloc>().add(
                              AuthSignUpRequested(
                                user: user,
                                password: _passwordController.text.trim(),
                              ),
                            );
                          }
                        },
                        child: const Text('S\'inscrire'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
