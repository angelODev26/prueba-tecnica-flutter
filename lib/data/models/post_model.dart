import 'package:hive/hive.dart';

part 'post_model.g.dart';

@HiveType(typeId: 0)
class PostModel {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String body;
  
  @HiveField(3)
  final int userId;
  
  @HiveField(4)
  final bool isFavorite;
  
  @HiveField(5)
  final DateTime? cachedAt;
  
  PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.isFavorite = false,
    this.cachedAt,
  });
  
  // AÑADE ESTE MÉTODO - FALTABA
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
      isFavorite: false,
      cachedAt: DateTime.now(),
    );
  }
  
  // AÑADE ESTE MÉTODO TAMBIÉN - FALTABA
  PostModel copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
    bool? isFavorite,
    DateTime? cachedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      isFavorite: isFavorite ?? this.isFavorite,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  String toString() {
    return 'Post $id: "$title"';
  }
}