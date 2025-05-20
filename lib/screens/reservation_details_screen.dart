import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/reservation_manager.dart';
import 'package:intl/intl.dart';

class ReservationDetailsScreen extends StatelessWidget {
  final Reservation reservation;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  ReservationDetailsScreen({
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
            _buildDetailItem('Data', _formatDate(reservation.date)),
            _buildDetailItem('Horário', _formatTime(reservation.time)),
            _buildDetailItem('Capacidade', '${reservation.capacity} pessoas'),
            _buildDetailItem('Status', reservation.status),
            if (reservation.status == 'Cancelada' && reservation.canceledAt != null)
              _buildDetailItem('Cancelada em', _dateFormat.format(reservation.canceledAt!)),

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
                    backgroundColor: Colors.red[400],
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

  void _navigateToEdit(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/editReservation',
      arguments: reservation,
    ).then((result) {
      if (result == true) {
        // Retorna true para a tela anterior para indicar que houve alteração
        Navigator.pop(context, true);
      }
    });
  }

  void _cancelReservation(BuildContext context) {
    // Usando apenas o método do ReservationManager para evitar duplicação de lógica
    ReservationManager.cancelReservation(reservation.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reserva cancelada com sucesso!'),
        duration: Duration(seconds: 2),
      ),
    );

    // Retorna true para a tela anterior para indicar que houve alteração
    Navigator.pop(context, true);
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

  // Métodos para formatação consistente
  String _formatDate(String date) {
    // Verifica se a data já está no formato correto
    if (date.contains('/')) return date;

    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (e) {
      debugPrint('Erro ao formatar data: $e');
    }
    return date;
  }

  String _formatTime(String time) {
    // Verifica se o horário já está no formato correto
    if (time.contains(':')) {
      final parts = time.split(':');
      if (parts.length == 2 && parts[1].length == 1) {
        // Adiciona zero à esquerda para minutos com um dígito
        return '${parts[0]}:${parts[1].padLeft(2, '0')}';
      }
    }
    return time;
  }
}