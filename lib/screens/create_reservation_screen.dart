

import 'package:coworking_app/services/reservation_service.dart';
import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/reservation_manager.dart';
import '../models/reservation_manager.dart';
import 'package:intl/intl.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});
  

  @override
  State<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workspaceNameController = TextEditingController();
  final _capacityController = TextEditingController(text: '4');
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  bool _isLoading = false;

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  // final DateFormat _backendDateTimeFormat = DateFormat('yyyy-MM-ddTHH:ms:ss');
  
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

  // // Verifica se já existe uma reserva para a mesma sala, data e horário
  // bool _isReservationDuplicate() {
  //   final reservations = ReservationManager.reservations;
  //   for (final res in reservations) {
  //     if (res.status == 'Ativa' && // Apenas reservas ativas
  //         res.roomName == _roomNameController.text &&
  //         res.date == _dateController.text &&
  //         res.time == _timeController.text) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  void _submit() async{
    final reservationService = ReservationService();

    if (!_formKey.currentState!.validate()) return;
      setState(() {
        _isLoading = true;
      });
    try{
      final selectedDate = _dateFormat.parse(_dateController.text);

      final userId = await reservationService.getUserId();

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: usuário não autenticado')),
        );
        return;
      }

      final newReservation = Reservation(
        workspaceName: _workspaceNameController.text,
        capacity: int.parse(_capacityController.text),
        date: selectedDate,
        startTime:  _startTimeController.text,
        endTime:  _endTimeController.text,
        status: 'Ativa',
        userId: userId, 
      );
      final success = await reservationService.createReservation(newReservation);
      

      if (!mounted) return;
      if(success){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reserva criada com sucesso!"),backgroundColor: Colors.green,)
        );
        
        Navigator.pop(context,true);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar reserva.'), backgroundColor: Colors.red)
        );
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado $e'), backgroundColor: Colors.red)
      );
    }finally{
      setState(() {
        _isLoading = false;
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
                keyboardType: TextInputType.number
                ),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildTimeFormat('Horario de início', _startTimeController),
              const SizedBox(height: 16),
              _buildTimeFormat('Horario de término', _endTimeController),
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
    TextInputType keyboardType = TextInputType.text
  }){
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon)
      ),
      keyboardType: keyboardType,
      validator: (value){
        if ( value == null || value.isEmpty){
          return 'Campo obrigatório';
        }if(label == 'Capacidade'){
          final parsed = int.tryParse(value);
          if (parsed == null || parsed <= 0){
            return 'Numero inválido';
          }
        }
        return null;
        }
    );
  }

  Widget _buildDateField(){
    return TextFormField(
      controller: _dateController,
      decoration: const InputDecoration(
        labelText: 'Data (DD/MM/AAAA)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today)
      ),
      readOnly: true,
      onTap: _selectDate,
      validator: (value){
        if (value == null || value.isEmpty){
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

  Widget _buildTimeFormat(String label, TextEditingController controller){
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.access_time)
      ),
      readOnly: true,
      onTap: () => _selectTime(controller),
      validator: (value){
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
