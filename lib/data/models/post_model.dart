import 'package:hive/hive.dart';

// @HiveType() le dice a Hive: "Esta clase se puede guardar en la base de datos"
// typeId: 0 es un ID único para este tipo (cada modelo necesita uno diferente)
part 'post_model.g.dart'; // Este archivo será GENERADO automáticamente

@HiveType(typeId: 0)
class PostModel {
  // @HiveField(0) asigna un ID único a cada campo
  // IMPORTANTE: Si cambias los campos después, NO cambies estos números
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
  final DateTime? cachedAt; // Fecha cuando se guardó en caché
  
  // Constructor
  PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.isFavorite = false,
    this.cachedAt,
  });

}