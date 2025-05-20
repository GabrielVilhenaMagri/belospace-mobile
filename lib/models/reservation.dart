// models/reservation.dart
class Reservation {
  final String id;
  final String roomName;
  final int capacity;
  final String date;
  final String time;
  final String status;
  final String userId;
  final DateTime? canceledAt; //

  Reservation({
    required this.id,
    required this.roomName,
    required this.capacity,
    required this.date,
    required this.time,
    required this.status,
    required this.userId,
    this.canceledAt, // Opcional
  });

  Reservation copyWith({
    String? id,
    String? roomName,
    int? capacity,
    String? date,
    String? time,
    String? status,
    String? userId,
    DateTime? canceledAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      capacity: capacity ?? this.capacity,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      canceledAt: canceledAt ?? this.canceledAt,
    );
  }

  bool get shouldBeRemoved {
    if (status != 'Cancelada' || canceledAt == null) return false;
    return DateTime.now().difference(canceledAt!).inDays > 10;
  }
}