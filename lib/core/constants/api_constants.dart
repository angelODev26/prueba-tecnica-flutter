abstract class ApiConstants {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  // Endpoints
  static const String postsEndpoint = '/posts';
  static const String usersEndpoint = '/users';
  static const String commentsEndpoint = '/comments';
  
  // Métodos HTTP
  static const String getMethod = 'GET';
  static const String postMethod = 'POST';
  static const String putMethod = 'PUT';
  static const String deleteMethod = 'DELETE';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Códigos de estado
  static const int successCode = 200;
  static const int createdCode = 201;
  static const int noContentCode = 204;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;
}