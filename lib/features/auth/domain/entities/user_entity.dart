import 'package:equatable/equatable.dart';

enum UserRole { cashier, customer }

class UserEntity extends Equatable {
  final String uid;
  final String fullName;
  final String phoneNumber;
  final String email;
  final UserRole role;

  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [uid, fullName, phoneNumber, email, role];
}
