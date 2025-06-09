import 'package:coworking_app/services/reservation_service.dart';
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
  // List<Reservation> _reservations = [];
  late Future<List<Map<String, dynamic>>> _reservationsFuture;
  static final _reservationService = ReservationService();
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _loadReservations();
    // ReservationManager.addListener(_loadReservations);
  }

  // @override
  // void dispose() {
  //   ReservationManager.removeListener(_loadReservations);
  //   super.dispose();
  // }

  Future<void> _loadReservations() async {
    final userId = await _reservationService.getUserId();
    if (mounted) {
      setState(() {
        _reservationsFuture = _reservationService.getReservationByUserId(
          userId!,
        );
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
      appBar:
          ModalRoute.of(context)?.settings.name == '/rooms'
              ? AppBar(title: const Text("Salas Disponíveis"))
              : null, // Só mostra header se acessada diretamente
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma reserva ativa encontrada\nClique no botão + para criar uma',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final reservations = snapshot.data!;
          final activeReservations =
              reservations.where((res) => res['status'] == 'Ativa').toList();

          if (activeReservations.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma reserva ativa encontrada\nClique no botão + para criar uma',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: activeReservations.length,
            itemBuilder: (context, index) {
              final res = activeReservations[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(res['workspaceName']),
                  subtitle: Text(
                    '${_dateFormat.parse(res['date'])} | ${_formatTime(res['startTime'])} às ${_formatTime(res['endTime'])}',
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    final reservation = Reservation.fromJson(res);
                    _navigateToDetails(reservation);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewReservation,
        child: const Icon(Icons.add),
      ),
    );
  }

  // // Métodos para formatação consistente
  // String _formatDate(String date) {
  //   // Verifica se a data já está no formato correto
  //   if (date.contains('/')) return date;

  //   try {
  //     final parts = date.split('-');
  //     if (parts.length == 3) {
  //       return '${parts[2]}/${parts[1]}/${parts[0]}';
  //     }
  //   } catch (e) {
  //     debugPrint('Erro ao formatar data: $e');
  //   }
  //   return date;
  // }

  String _formatTime(String time) {
    // Verifica se o horário já está no formato correto
    if (time.contains(':')) {
      final parts = time.split(':');
      if (parts.length == 2 && parts[1].length == 1) {
        // Adiciona zero à esquerda para minutos com um dígito
        return "${parts.toString().padLeft(2, '0')}:${parts.toString().padLeft(2, '0')}";
      }
    }
    return time;
  }
}
