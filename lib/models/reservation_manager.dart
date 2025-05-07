import 'package:flutter/material.dart';
import 'reservation.dart';

class ReservationManager {
  static final List<Reservation> _reservations = [];
  static final List<VoidCallback> _listeners = [];

  // Retorna todas as reservas (ativas e canceladas)
  static List<Reservation> get reservations => List.unmodifiable(_reservations);

  // Retorna apenas reservas ativas (não expiradas)
  static List<Reservation> get activeReservations =>
      _reservations.where((res) => !res.shouldBeRemoved).toList();

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void addReservation(Reservation reservation) {
    _reservations.add(reservation);
    _notifyListeners();
    debugPrint('✅ Reserva adicionada: ${reservation.roomName}');
  }

  static void updateReservation(Reservation updatedReservation) {
    final index = _reservations.indexWhere((r) => r.id == updatedReservation.id);
    if (index != -1) {
      _reservations[index] = updatedReservation;
      _notifyListeners();
      debugPrint('🔄 Reserva atualizada: ${updatedReservation.roomName}');
    }
  }

  static void cancelReservation(String reservationId) {
    final index = _reservations.indexWhere((res) => res.id == reservationId);
    if (index != -1) {
      final reservation = _reservations[index];
      final updatedReservation = Reservation(
        id: reservation.id,
        roomName: reservation.roomName,
        capacity: reservation.capacity,
        date: reservation.date,
        time: reservation.time,
        status: 'Cancelada',
        userId: reservation.userId,
        canceledAt: DateTime.now(),
      );
      _reservations[index] = updatedReservation;
      _notifyListeners();
      debugPrint('🚫 Reserva cancelada: ${reservation.roomName}');
    }
  }

  static void cleanExpiredCancellations() {
    final initialCount = _reservations.length;
    _reservations.removeWhere((res) => res.shouldBeRemoved);

    if (_reservations.length < initialCount) {
      _notifyListeners();
      debugPrint('🧹 Removidas ${initialCount - _reservations.length} reservas canceladas expiradas');
    }
  }

  static void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  static void clear() {
    _reservations.clear();
    _notifyListeners();
  }
}