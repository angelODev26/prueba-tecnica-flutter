import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime lastLogin;

  UserModel({
    required this.userId,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.lastLogin,
  });

  /// Crea copia con campos opcionales modificados
  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() => 'UserModel(userId: $userId, email: $email, displayName: $displayName)';
}
