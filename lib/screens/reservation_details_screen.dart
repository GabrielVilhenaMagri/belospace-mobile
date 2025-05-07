import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/reservation_manager.dart';
import 'edit_reservation_screen.dart'; // Verifique o caminho correto

class ReservationDetailsScreen extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailsScreen({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Sala', reservation.roomName),
            _buildDetailItem('Data', reservation.date),
            _buildDetailItem('Horário', reservation.time),
            _buildDetailItem('Capacidade', '${reservation.capacity} pessoas'),
            _buildDetailItem('Status', reservation.status),

            const SizedBox(height: 32),
            if (reservation.status == 'Ativa') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditReservationScreen(
                          reservation: reservation,
                        ),
                      ),
                    );
                  },
                  child: const Text('Editar Reserva'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    final updatedReservation = Reservation(
                      id: reservation.id,
                      roomName: reservation.roomName,
                      capacity: reservation.capacity,
                      date: reservation.date,
                      time: reservation.time,
                      status: 'Cancelada',
                      userId: reservation.userId,
                      canceledAt: DateTime.now(), // Novo campo
                    );
                    ReservationManager.updateReservation(updatedReservation);
                    ReservationManager.cancelReservation(reservation.id); // Chama o método
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reserva cancelada com sucesso!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context); // Fecha a tela de detalhes
                  },
                  child: const Text(
                    'CANCELAR RESERVA',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
          const Divider(),
        ],
      ),
    );
  }
}