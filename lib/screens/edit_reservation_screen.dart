import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/reservation_manager.dart';


class EditReservationScreen extends StatefulWidget {
  final Reservation reservation;

  const EditReservationScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<EditReservationScreen> createState() => _EditReservationScreenState();
}

class _EditReservationScreenState extends State<EditReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _roomNameController;
  late final TextEditingController _capacityController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    // Pré-preenche os campos com os dados atuais
    _roomNameController = TextEditingController(text: widget.reservation.roomName);
    _capacityController = TextEditingController(text: widget.reservation.capacity.toString());
    _dateController = TextEditingController(text: widget.reservation.date);
    _timeController = TextEditingController(text: widget.reservation.time);
  }

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
      final updatedReservation = Reservation(
        id: widget.reservation.id,
        roomName: _roomNameController.text,
        capacity: int.parse(_capacityController.text),
        date: _dateController.text,
        time: _timeController.text,
        status: widget.reservation.status,
        userId: widget.reservation.userId,
        canceledAt: widget.reservation.canceledAt, // Mantém o valor existente
      );

      ReservationManager.updateReservation(updatedReservation);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Reserva')),
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
                  child: const Text('ATUALIZAR RESERVA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}