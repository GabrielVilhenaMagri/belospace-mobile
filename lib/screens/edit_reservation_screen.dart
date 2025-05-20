import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/reservation_manager.dart';
import 'package:intl/intl.dart';

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
  bool _isLoading = false;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

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
    // Tenta converter a data atual para DateTime
    DateTime initialDate;
    try {
      final parts = widget.reservation.date.split('/');
      if (parts.length == 3) {
        initialDate = DateTime(
          int.parse(parts[2]), // ano
          int.parse(parts[1]), // mês
          int.parse(parts[0]), // dia
        );
      } else {
        initialDate = DateTime.now();
      }
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(DateTime.now()) ? initialDate : DateTime.now(),
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
    // Tenta converter o horário atual para TimeOfDay
    TimeOfDay initialTime;
    try {
      final parts = widget.reservation.time.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } else {
        initialTime = TimeOfDay.now();
      }
    } catch (e) {
      initialTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {

        _timeController.text = "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }


  bool _isReservationDuplicate() {
    final reservations = ReservationManager.reservations;
    for (final res in reservations) {
      if (res.id != widget.reservation.id && // Não é a mesma reserva
          res.status == 'Ativa' && // Apenas reservas ativas
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

      final updatedReservation = Reservation(
        id: widget.reservation.id,
        roomName: _roomNameController.text,
        capacity: int.parse(_capacityController.text),
        date: _dateController.text,
        time: _timeController.text,
        status: widget.reservation.status,
        userId: widget.reservation.userId,
        canceledAt: widget.reservation.canceledAt,
      );

      // Simulação de operação assíncrona
      Future.delayed(const Duration(milliseconds: 300), () {
        ReservationManager.updateReservation(updatedReservation);

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Retorna true para indicar que houve alteração
        Navigator.pop(context, true);
      });
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
                      : const Text('ATUALIZAR RESERVA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}