/// Excepción personalizada para indicar que los datos vinieron del caché
class CacheException implements Exception {
  final String message;
  final int itemCount;

  CacheException({
    required this.message,
    required this.itemCount,
  });

  @override
  String toString() => message;
}
