import 'package:intl/intl.dart';

class Reservation {
  final String workspaceName;
  final int capacity;
  final DateTime date;
  final String status;
  final int userId;
  final DateTime? canceledAt;
  final int? id;

  Reservation({
    required this.workspaceName,
    required this.capacity,
    required this.date,
    required this.status,
    required this.userId,
    this.canceledAt,
    this.id,
  });

  Reservation copyWith({
    String? workspaceName,
    int? capacity,
    DateTime? date,
    String? status,
    int? userId,
    DateTime? canceledAt,
    int? id,
  }) {
    return Reservation(
      workspaceName: workspaceName ?? this.workspaceName,
      capacity: capacity ?? this.capacity,
      date: date ?? this.date,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      canceledAt: canceledAt ?? this.canceledAt,
      id: id ?? this.id,
    );
  }

  bool get shouldBeRemoved {
    if (status != 'Cancelada' || canceledAt == null) return false;
    return DateTime.now().difference(canceledAt!).inDays > 10;
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      workspaceName: json['workspaceName'],
      capacity: json['capacity'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      userId: json['userId'],
      canceledAt: json['canceledAt'] != null && json['canceledAt'] != ''
          ? DateTime.parse(json['canceledAt'])
          : null,
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workspaceName': workspaceName,
      'capacity': capacity,
      'date': DateFormat('yyyy-MM-dd').format(date), // formato LocalDate
      'status': status,
      'userId': userId,
      'canceledAt': canceledAt?.toIso8601String(),
      if (id != null) 'id': id,
    };
  }
}
