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
  Timer? _cleanupTimer;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Corrigido: Timer agora é armazenado para cancelamento adequado
    _cleanupTimer = Timer.periodic(const Duration(hours: 24), (timer) {
      if (mounted) {
        ReservationManager.cleanExpiredCancellations();
        setState(() {}); // Força reconstrução apenas quando necessário
      }
    });

    // Registra listener para atualizações de reservas
    ReservationManager.addListener(_onReservationsChanged);
  }

  @override
  void dispose() {
    // Corrigido: Cancelamento do timer para evitar vazamento de memória
    _cleanupTimer?.cancel();
    // Remove o listener para evitar callbacks em widgets desmontados
    ReservationManager.removeListener(_onReservationsChanged);
    super.dispose();
  }

  // Método para atualizar o estado quando as reservas mudarem
  void _onReservationsChanged() {
    if (mounted) {
      setState(() {
        // Estado atualizado apenas quando o widget está montado
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memoização da lista filtrada para evitar recálculos desnecessários
    final userReservations = _getUserReservations();

    return Scaffold(
      appBar: ModalRoute.of(context)?.settings.name == '/reservations'
          ? const CustomHeader(title: "Minhas Reservas")
          : null, // Só mostra header se acessada diretamente
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildReservationsList(userReservations)),
        ],
      ),
    );
  }

  // Método extraído para melhorar a legibilidade e manutenção
  List<Reservation> _getUserReservations() {
    return ReservationManager.reservations
        .where((res) => res.userId == widget.currentUserId)
        .where((res) => _filterStatus == 'Todas' || res.status == _filterStatus)
        .toList();
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
                // Formatação consistente de data
                Text('${_formatDate(reservation.date)} às ${_formatTime(reservation.time)}'),
                if (reservation.status == 'Cancelada' && reservation.canceledAt != null)
                  Text(
                    'Cancelada em ${_dateFormat.format(reservation.canceledAt!)}',
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
            onTap: () => _navigateToDetails(reservation),
          ),
        );
      },
    );
  }

  // Método para navegação consistente
  void _navigateToDetails(Reservation reservation) {
    Navigator.pushNamed(
      context,
      '/reservationDetails',
      arguments: reservation,
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