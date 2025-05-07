import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/reservation_manager.dart';
import 'reservation_details_screen.dart';
import '../components/header.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ReservationsScreen extends StatefulWidget {
  final String currentUserId; // Recebe o ID do usuário logado

  const ReservationsScreen({super.key, required this.currentUserId});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  String _filterStatus = 'Ativa';



  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(hours: 24), (timer) {
      if (mounted) {
        ReservationManager.cleanExpiredCancellations();
        setState(() {}); // Força reconstrução
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userReservations = ReservationManager.reservations
        .where((res) => res.userId == widget.currentUserId)
        .where((res) => _filterStatus == 'Todas' || res.status == _filterStatus)
        .toList();

    return Scaffold(
      appBar: const CustomHeader(title: "Minhas Reservas"),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildReservationsList(userReservations)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('Filtrar: ', style: TextStyle(fontSize: 16)),
          Wrap(
            spacing: 8,
            children: ['Todas', 'Ativa', 'Cancelada'].map((status) {
              return FilterChip(
                label: Text(status),
                selected: _filterStatus == status,
                onSelected: (selected) {
                  setState(() {
                    _filterStatus = selected ? status : 'Todas';
                  });
                },
                selectedColor: Colors.amber[100],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(List<Reservation> reservations) {
    if (reservations.isEmpty) {
      return const Center(
        child: Text('Nenhuma reserva encontrada', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return Card(
          color: reservation.status == 'Cancelada' ? Colors.grey[200] : null,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(
              reservation.roomName,
              style: TextStyle(
                decoration: reservation.status == 'Cancelada'
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${reservation.date} às ${reservation.time}'),
                if (reservation.status == 'Cancelada')
                  Text(
                    'Cancelada em ${DateFormat('dd/MM/yyyy').format(reservation.canceledAt!)}',
                    style: TextStyle(color: Colors.red[400], fontSize: 12),
                  ),
              ],
            ),
            trailing: Chip(
              label: Text(reservation.status),
              backgroundColor: reservation.status == 'Ativa'
                  ? Colors.green[100]
                  : Colors.red[100],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservationDetailsScreen(
                  reservation: reservation,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}