import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';

class ReservationService {
  final _storage = const FlutterSecureStorage();

  static const String _baseUrl = 'http://192.168.15.103:8082/api/booking';

  Future<bool> createReservation(Reservation reservation) async {
    // final token = await _storage.read(key: 'jwt_token');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(reservation.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('id')) {
        await _storage.write(
          key: 'reservation_id',
          value: data['id'].toString(),
        );
      }
      print('print do id da reserva: ${data['id']}');
      print(await _storage.read(key: 'reservation_id'));

      return true;
    } else {
      print('Erro: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  Future<bool> updateReservation(Reservation updateReservation) async {
    final reservationId = await (_storage.read(key: 'reservation_id')) ?? '';
    if (reservationId.isEmpty) {
      print('Reservation ID está vazio!');
      return false;
    }
    final url = Uri.parse('$_baseUrl/update/$reservationId');
    // final token = await _storage.read(key: 'jwt_token');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateReservation.toJson()),
      // jsonEncode({
      //   "workspaceName": updateReservation.workspaceName,
      //   "capacity": updateReservation.capacity,
      //   "date": updateReservation.date,
      //   "startTime": updateReservation.startTime,
      //   "endTime": updateReservation.endTime,
      //   "status": updateReservation.status,
      //   "userId": updateReservation.userId,
      //   // "canceledAt": updateReservation.canceledAt,
      // }),
    );
    return response.statusCode == 200;
  }

Future<bool> cancelReservation(int id) async {
  final url = Uri.parse('$_baseUrl/$id');
  final token = await _storage.read(key: 'jwt_token');

  final response = await http.patch(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    
  );

  return response.statusCode == 200;
}

  Future<List<Map<String, dynamic>>> getReservationByUserId(int userId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$_baseUrl/userId/$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else if (response.statusCode == 404) {
      // Nenhuma reserva encontrada
      return [];
    } else {
      throw Exception('Erro ao carregar reservas: ${response.statusCode}');
    }
  }

  Future<int?> getUserId() async {
    final jsonStr = await _storage.read(key: 'user_data');
    if (jsonStr != null) {
      final json = jsonDecode(jsonStr);
      return json["id"];
    }
    return null;
  }

  Future<int?> getReservationId() async {
    final srtId = await _storage.read(key: 'reservation_id');
    if (srtId != null) {
      final id = int.tryParse(srtId);
      print(id);
      return id;
    }
    return null;
  }
}
