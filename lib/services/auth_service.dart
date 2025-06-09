import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  static const _baseUrl = 'http://192.168.15.103:8081/api/auth';
  static final _storage = FlutterSecureStorage();

  /// Faz login e retorna um Map com token e user, ou null se falhar
  static Future<bool?> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final String token = data['token'];
      final user = data['userData'];

      await _storage.write(key: 'jwt_token', value: token);
      await _storage.write(key: 'user_data', value: jsonEncode(user));
      print('JSON salvo: ${jsonEncode(user)}');
      print('Login bem-sucedido: $user');

      return true;
    }else {
    print('Erro no login: ${res.statusCode} - ${res.body}');
    return false; 
    }
  }

  static Future<bool> register(
    String username,
    String email,
    String password,
  ) async {
    final url1 = Uri.parse('$_baseUrl/register');

    final response = await http.post(
      url1,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return response.statusCode == 200;
  }
}
