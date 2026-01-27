import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  
  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.postsEndpoint}');
      
      print('Fetching posts from URL: $url');

      // Headers básicos
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await _client
          .get(url, headers: headers)
          .timeout(ApiConstants.receiveTimeout);
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == ApiConstants.successCode) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('Successfully fetched ${jsonList.length} posts');
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        // Manejo detallado de errores
        print('Response body: ${response.body}');
        
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = 'Bad Request';
            break;
          case 401:
            errorMessage = 'Unauthorized';
            break;
          case 403:
            errorMessage = 'Forbidden - Check API permissions';
            break;
          case 404:
            errorMessage = 'Not Found';
            break;
          case 500:
            errorMessage = 'Internal Server Error';
            break;
          default:
            errorMessage = 'HTTP Error ${response.statusCode}';
        }
        throw Exception('API Error: $errorMessage');
      }
    } on TimeoutException {
      throw Exception('Request timeout. Check your internet connection.');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Data format error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  Future<Map<String, dynamic>> getPostDetail(int id) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.postsEndpoint}/$id');
      
      final response = await _client
          .get(url)
          .timeout(ApiConstants.receiveTimeout);
      
      if (response.statusCode == ApiConstants.successCode) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage;
        switch (response.statusCode) {
          case ApiConstants.badRequestCode:
            errorMessage = 'Solicitud incorrecta';
            break;
          case ApiConstants.unauthorizedCode:
            errorMessage = 'No autorizado';
            break;
          case ApiConstants.notFoundCode:
            errorMessage = 'Post no encontrado';
            break;
          case ApiConstants.serverErrorCode:
            errorMessage = 'Error del servidor';
            break;
          default:
            errorMessage = 'Error ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Verifica tu conexión.');
    } on http.ClientException catch (e) {
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}