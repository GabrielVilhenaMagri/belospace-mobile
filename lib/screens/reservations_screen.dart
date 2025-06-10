import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coworking_app/services/reservation_service.dart';
import 'package:coworking_app/models/reservation.dart';
import 'package:coworking_app/utils/app_colors.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late Future<List<Map<String, dynamic>>> _reservationsFuture;
  static final _reservationService = ReservationService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  String _filterStatus = 'Ativa';

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final userId = await _reservationService.getUserId();
    if (mounted) {
      setState(() {
        _reservationsFuture = _reservationService.getReservationByUserId(userId!);
      });
    }
  }

  void _navigateToDetails(Reservation reservation) {
    Navigator.pushNamed(context, '/reservationDetails', arguments: reservation)
        .then((result) {
      if (result == true) {
        _loadReservations();
      }
    });
  }

  void _createNewReservation() {
    Navigator.pushNamed(context, '/createReservation').then((result) {
      if (result == true) {
        _loadReservations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Minhas Reservas")),
      body: Column(
        children: [
          _buildFilterChips(theme),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _reservationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma reserva encontrada.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final reservations = snapshot.data!
                    .where((res) => _filterStatus == 'Todas' || res['status'] == _filterStatus)
                    .toList();

                if (reservations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhuma reserva com status "$_filterStatus".',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final res = reservations[index];
                    final reservation = Reservation.fromJson(res);
                    final isCancelled = reservation.status == 'Cancelada';

                    return Card(
                      color: isCancelled ? AppColors.darkBlue.withOpacity(0.7) : theme.cardTheme.color,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        title: Text(
                          reservation.workspaceName,
                          style: isCancelled ? theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.textGrey,
                          ) : theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.textDark,
                            decoration: null,
                            decorationColor: AppColors.textDark,
                          )
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${_formatDate(reservation.date.toString())}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: isCancelled ? AppColors.white : AppColors.textDark),
                            ),
                            if (isCancelled && reservation.canceledAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Cancelada em: ${_dateFormat.format(reservation.canceledAt!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.cancelRed.withOpacity(0.8)),
                                ),
                              ),
                          ],
                        ),
                        trailing: _buildStatusChip(theme, reservation.status),
                        onTap: () => _navigateToDetails(reservation),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewReservation,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: ["Todas", "Ativa", "Cancelada"].map((status) {
          final bool isSelected = _filterStatus == status;
          return FilterChip(
            label: Text(status),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _filterStatus = selected ? status : "Todas";
              });
            },
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? AppColors.white : AppColors.textDark,
            ),
            backgroundColor: AppColors.white,
            selectedColor: theme.colorScheme.primary,
            checkmarkColor: AppColors.white,
            shape: StadiumBorder(
              side: BorderSide(color: isSelected ? theme.colorScheme.primary : AppColors.borderGrey),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, String status) {
    Color chipColor;
    Color textColor;

    switch (status) {
      case 'Ativa':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Cancelada':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        chipColor = Colors.grey.shade300;
        textColor = Colors.grey.shade800;
    }

    return Chip(
      label: Text(status),
      labelStyle: theme.textTheme.bodySmall?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(String date) {
    try {
      return _dateFormat.format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    return time;
  }
}
