// models/reservation.dart

import 'package:intl/intl.dart';

class Reservation {
  final String workspaceName;
  final int capacity;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final int userId;
  final DateTime? canceledAt; //

  Reservation({
    required this.workspaceName,
    required this.capacity,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.userId,
    this.canceledAt, // Opcional
  });

  Reservation copyWith({
    String? workspaceName,
    int? capacity,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? status,
    int? userId,
    DateTime? canceledAt,
  }) {
    return Reservation(
      workspaceName: workspaceName ?? this.workspaceName,
      capacity: capacity ?? this.capacity,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      canceledAt: canceledAt ?? this.canceledAt,
    );
  }

  bool get shouldBeRemoved {
    if (status != 'Cancelada' || canceledAt == null) return false;
    return DateTime.now().difference(canceledAt!).inDays > 10;
  }

  factory Reservation.fromJson(Map<String,dynamic> json){
    return Reservation(
      workspaceName: json['workspaceName'],
      capacity: json['capacity'],
      date: DateFormat('dd-MM-yyyy').parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
      userId: json['userId'],
      canceledAt: json['canceledAt'] != null && json['canceledAt'] != ''
        ? DateTime.parse(json['canceledAt'])
        : null,
  );
  }

  Map<String, dynamic> toJson() {
    return {
      'workspaceName': workspaceName,
      'capacity': capacity,
      'date': DateFormat('dd-MM-yyyy').format(date),
      'userId': userId,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
      'canceledAt': canceledAt?.toIso8601String(),
    };
  }
}
