import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/reservation_manager.dart';
import 'package:intl/intl.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<Reservation> _reservations = [];
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadReservations();
    ReservationManager.addListener(_loadReservations);
  }

  @override
  void dispose() {
    ReservationManager.removeListener(_loadReservations);
    super.dispose();
  }

  void _loadReservations() {
    if (mounted) {
      setState(() {
        _reservations = ReservationManager.reservations;
        debugPrint('🔄 Lista atualizada com ${_reservations.length} reservas');
      });
    }
  }

  void _navigateToDetails(Reservation reservation) {
    Navigator.pushNamed(
      context,
      '/reservationDetails',
      arguments: reservation,
    ).then((result) {
      if (result == true) {
        // Só atualiza se houver mudanças
        _loadReservations();
      }
    });
  }

  void _createNewReservation() {
    Navigator.pushNamed(context, '/createReservation').then((result) {
      if (result == true) {
        // Só atualiza se houver mudanças
        _loadReservations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModalRoute.of(context)?.settings.name == '/rooms'
          ? AppBar(title: const Text("Salas Disponíveis"))
          : null, // Só mostra header se acessada diretamente
      body: _buildReservationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewReservation,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReservationsList() {
    if (_reservations.isEmpty) {
      return const Center(
        child: Text(
            'Nenhuma reserva encontrada\nClique no botão + para criar uma',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18)),
      );
    }

    // Filtra apenas reservas ativas para exibição
    final activeReservations = _reservations
        .where((res) => res.status == 'Ativa')
        .toList();

    if (activeReservations.isEmpty) {
      return const Center(
        child: Text(
            'Nenhuma reserva ativa encontrada\nClique no botão + para criar uma',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: activeReservations.length,
      itemBuilder: (context, index) {
        final reservation = activeReservations[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(reservation.roomName),
            subtitle: Text('${_formatDate(reservation.date)} às ${_formatTime(reservation.time)}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _navigateToDetails(reservation),
          ),
        );
      },
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