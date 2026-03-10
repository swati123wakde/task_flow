import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  String get name => displayName ?? email.split('@').first;

  String get initials {
    final n = name.trim();
    if (n.isEmpty) return '?';
    final parts = n.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return n[0].toUpperCase();
  }

  factory UserModel.fromFirebaseUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}