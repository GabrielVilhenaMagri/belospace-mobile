import 'package:coworking_app/services/reservation_service.dart';
import 'package:flutter/material.dart';
import '../models/reservation.dart';
import 'package:intl/intl.dart';

class EditReservationScreen extends StatefulWidget {
  final Reservation reservation;
  const EditReservationScreen({super.key, required this.reservation});

  @override
  State<EditReservationScreen> createState() => _EditReservationScreenState();
}

class _EditReservationScreenState extends State<EditReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _workspaceNameController;
  late final TextEditingController _capacityController;
  late final TextEditingController _dateController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;

  final ReservationService _reservationService = ReservationService();

  // final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  bool _isLoading = false;


@override
void initState() {
  super.initState();

  _workspaceNameController = TextEditingController(
    text: widget.reservation.workspaceName,
  );
  _capacityController = TextEditingController(
    text: widget.reservation.capacity.toString(),
  );
  _dateController = TextEditingController(
    text: _dateFormat.format(widget.reservation.date),
  );
}

  @override
  void dispose() {
    _workspaceNameController.dispose();
    _capacityController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = _dateFormat.format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  // bool _isReservationDuplicate() {
  //   final reservations = ReservationManager.reservations;
  //   for (final res in reservations) {
  //     if (res.id != widget.reservation.id && // Não é a mesma reserva
  //         res.status == 'Ativa' && // Apenas reservas ativas
  //         res.roomName == _roomNameController.text &&
  //         res.date == _dateController.text &&
  //         res.time == _timeController.text) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final updatedReservation = Reservation(
        workspaceName: _workspaceNameController.text,
        capacity: int.parse(_capacityController.text),
        date: _dateFormat.parse(_dateController.text),
        status: widget.reservation.status,
        userId: widget.reservation.userId,
      );

      final successUpdate = await _reservationService.updateReservation(
        updatedReservation,
      );

      if (!mounted) return;
      if (successUpdate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao atualizar reserva'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              _buildTextField(
                controller: _workspaceNameController,
                label: 'Nome da sala',
                icon: Icons.meeting_room,
                
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _capacityController,
                label: 'Capacidade',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                readOnly: true
              ),
              const SizedBox(height: 16),
              _buildDateField(),            
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child:
                      _isLoading
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

  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool readOnly = false, // Novo parâmetro para controlar se é editável
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      prefixIcon: Icon(icon),
    ),
    keyboardType: keyboardType,
    readOnly: readOnly,  // Aqui aplicamos o readOnly
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Campo obrigatório';
      }
      if (label == 'Capacidade') {
        final parsed = int.tryParse(value);
        if (parsed == null || parsed <= 0) {
          return 'Numero inválido';
        }
      }
      return null;
    },
  );
}

  Widget _buildDateField() {
    return TextFormField(
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
        final dateRegex = RegExp(r'^\d{1,2}-\d{1,2}-\d{4}$');
        if (!dateRegex.hasMatch(value)) {
          return 'Formato de data inválido';
        }
        return null;
      },
    );
  }

  Widget _buildTimeFormat(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.access_time),
      ),
      readOnly: true,
      onTap: () => _selectTime(controller),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Selecione um horario';
        final timeRegex = RegExp(r'^\d{1,2}:\d{2}$');
        if (!timeRegex.hasMatch(value)) {
          return 'Formato de horário inválido';
        }
        return null;
      },
    );
  }
}
