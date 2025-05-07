// screens/create_reservation_screen.dart
import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import '../../models/reservation_manager.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _capacityController = TextEditingController(text: '4');
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    _capacityController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      _timeController.text = "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newReservation = Reservation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          roomName: _roomNameController.text,
          capacity: int.parse(_capacityController.text),
          date: _dateController.text,
          time: _timeController.text,
          status: 'Ativa',
          userId: 'user123', // Substitua pelo ID real
      );

      ReservationManager.addReservation(newReservation);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Reserva')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Sala',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacidade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Campo obrigatório';
                  final capacity = int.tryParse(value);
                  if (capacity == null || capacity <= 0) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data (DD/MM/AAAA)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) => value!.isEmpty ? 'Selecione uma data' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Horário (HH:MM)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: _selectTime,
                validator: (value) => value!.isEmpty ? 'Selecione um horário' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('CRIAR RESERVA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}