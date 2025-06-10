import 'package:flutter/material.dart';
import '../models/reservation.dart';
import 'package:coworking_app/services/reservation_service.dart';
import 'package:intl/intl.dart';

class ReservationDetailsScreen extends StatelessWidget {
  
  final Reservation reservation;

  ReservationDetailsScreen({super.key, required this.reservation});
  final ReservationService _reservationService = ReservationService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Sala', reservation.workspaceName),
            _buildDetailItem('Data', _dateFormat.format(reservation.date)),
            // _buildDetailItem(
            //   'Horário inicial',
            //   reservation.startTime,
            // ),
            // _buildDetailItem(
            //   'Horário final',
            //   reservation.endTime,
            // ),
            _buildDetailItem('Capacidade', '${reservation.capacity} pessoas'),
            _buildDetailItem('Status', reservation.status),
            if (reservation.status == 'Cancelada' &&
                reservation.canceledAt != null)
              _buildDetailItem(
                'Cancelada em',
                _dateFormat.format(reservation.canceledAt!),
              ),

            const SizedBox(height: 32),
            if (reservation.status == 'Ativa') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToEdit(context),
                  child: const Text('Editar Reserva'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _cancelReservation(context),
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

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      '/editReservation',
      arguments: reservation,
    );

    if (context.mounted && result == true) {
      Navigator.pop(context, true);
    }
  }

void _cancelReservation(BuildContext context) async {
  final reservationId = await _reservationService.getReservationId();

  if (reservationId != null) {
    final success = await _reservationService.cancelReservation(reservationId);

    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva cancelada com sucesso!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao cancelar reserva'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID da reserva não encontrado.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

  // Retorna true para a tela anterior para indicar que houve alteração

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: const TextStyle(fontSize: 18)),
          const Divider(),
        ],
      ),
    );
  }
}
