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
      
      final response = await _client
          .get(url)
          .timeout(ApiConstants.receiveTimeout);
      
      if (response.statusCode == ApiConstants.successCode) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
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
            errorMessage = 'Recurso no encontrado';
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