import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/reservation_manager.dart';
import 'package:intl/intl.dart';

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
  bool _isLoading = false;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Simulação de dados
  static const String _currentUserId = 'user123';

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
      setState(() {
        _dateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        // Formatação adequada dos minutos
        _timeController.text = "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // Verifica se já existe uma reserva para a mesma sala, data e horário
  bool _isReservationDuplicate() {
    final reservations = ReservationManager.reservations;
    for (final res in reservations) {
      if (res.status == 'Ativa' && // Apenas reservas ativas
          res.roomName == _roomNameController.text &&
          res.date == _dateController.text &&
          res.time == _timeController.text) {
        return true;
      }
    }
    return false;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Verifica duplicação
      if (_isReservationDuplicate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Já existe uma reserva para esta sala nesta data e horário'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final newReservation = Reservation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomName: _roomNameController.text,
        capacity: int.parse(_capacityController.text),
        date: _dateController.text,
        time: _timeController.text,
        status: 'Ativa',
        userId: _currentUserId,
      );

      // Simulação de operação assíncrona
      Future.delayed(const Duration(milliseconds: 300), () {
        ReservationManager.addReservation(newReservation);

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      });
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
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
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  final capacity = int.tryParse(value);
                  if (capacity == null || capacity <= 0) {
                    return 'Número inválido';
                  }
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione uma data';
                  }
                  // Validação do formato da data
                  final dateRegex = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
                  if (!dateRegex.hasMatch(value)) {
                    return 'Formato de data inválido';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione um horário';
                  }
                  // Validação do formato da hora
                  final timeRegex = RegExp(r'^\d{1,2}:\d{2}$');
                  if (!timeRegex.hasMatch(value)) {
                    return 'Formato de horário inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('CRIAR RESERVA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}