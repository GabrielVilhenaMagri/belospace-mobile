// screens/rooms_screen.dart
import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import '../../models/reservation_manager.dart';
import 'reservation_details_screen.dart';
import '../components/header.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {

  void _navigateToDetails(Reservation reservation) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDetailsScreen(
          reservation: reservation,
        ),
      ),
    );

    if (shouldRefresh == true) {
      _loadReservations();
    }
  }

  List<Reservation> _reservations = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModalRoute.of(context)?.settings.name == '/rooms'
          ? const CustomHeader(title: "Salas Disponíveis")
          : null, // Só mostra header se acessada diretamente
      body: _buildReservationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/createReservation');
          _loadReservations();
        },
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

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(reservation.roomName),
            subtitle: Text('${reservation.date} às ${reservation.time}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _navigateToDetails(reservation),
          ),
        );
      },
    );
  }
}