import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/reservation_manager.dart';
import 'package:intl/intl.dart';
import 'package:coworking_app/utils/app_colors.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final List<Map<String, dynamic>> _availableRooms = [
    {
      'id': 'room1',
      'name': 'Sala Privativa 1',
      'capacity': 4,
      'imagePath': 'assets/images/2de943ab-b3af-4451-a5c6-b275b23ed0d7.jpg',
      'description': 'Espaço tranquilo e reservado para equipes pequenas.',
    },
    {
      'id': 'room2',
      'name': 'Sala de Reunião Alpha',
      'capacity': 8,
      'imagePath': 'assets/images/158a420c-4099-4b7d-835f-061f03bbf473.jpg',
      'description':
          'Equipada com TV e quadro branco, ideal para apresentações.',
    },
    {
      'id': 'room3',
      'name': 'Mesa Privativa Beta',
      'capacity': 1,
      'imagePath': 'assets/images/22441bb1-c79e-466c-9a3f-8e7683546277.jpg',
      'description':
          'Estação de trabalho individual em ambiente compartilhado.',
    },
    {
      'id': 'room4',
      'name': 'Auditório Lab',
      'capacity': 20,
      'imagePath': 'assets/images/d05872d2-0f56-4aa8-85cc-6731e27ef119.jpg',
      'description': 'Espaço amplo para eventos e workshops.',
    },
  ];

  DateTime? _selectedDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
  }

  void _selectRoom(String roomName, int capacity) {
    Navigator.pushNamed(
      context,
      '/createReservation',
      arguments: {'roomName': roomName, 'capacity': capacity},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _availableRooms.length,
        itemBuilder: (context, index) {
          final room = _availableRooms[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            color: AppColors.darkBlue, // escurece o card
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      room["imagePath"],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    room['name'],
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        color: AppColors.textGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${room['capacity']} pessoa(s)',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room['description'],
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          () => _selectRoom(room['name'], room['capacity']),
                      child: const Text("Reservar"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
