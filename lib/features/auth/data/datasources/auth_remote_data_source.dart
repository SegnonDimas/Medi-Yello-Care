import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(UserModel user, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get onAuthStateChanged;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signIn(String email, String password) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (credential.user == null) throw Exception('User not found');
    
    final doc = await firestore.collection('users').doc(credential.user!.uid).get();
    if (!doc.exists) throw Exception('User profile not found in Firestore');
    
    return UserModel.fromMap(doc.data()!);
  }

  @override
  Future<UserModel> signUp(UserModel user, String password) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );

    if (credential.user == null) throw Exception('Sign up failed');

    final userModelWithId = UserModel(
      uid: credential.user!.uid,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      email: user.email,
      role: user.role,
    );

    await firestore.collection('users').doc(userModelWithId.uid).set(userModelWithId.toMap());

    return userModelWithId;
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    
    final doc = await firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    
    return UserModel.fromMap(doc.data()!);
  }

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }
}
