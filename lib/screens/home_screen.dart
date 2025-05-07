import 'package:flutter/material.dart';
import '../components/header.dart';
import 'rooms_screen.dart';
import 'reservations_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final String _currentUserId = 'user123'; // Substitua pelo ID real do usuário logado
  final String _userName = 'João Silva'; // Substitua pelo nome real
  final String _userEmail = 'joao@exemplo.com'; // Substitua pelo email real

  // Telas correspondentes a cada aba
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const RoomsScreen(),
      ReservationsScreen(currentUserId: 'user123'), // Use o ID real
      const Center(child: Text('Tela Sobre')), // Substitua pela tela Sobre quando criada
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: _getAppBarTitle(),
        showBackButton: false,
        onProfileTap: () => _navigateToProfile(context),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Salas Disponíveis';
      case 1:
        return 'Minhas Reservas';
      case 2:
        return 'Sobre';
      default:
        return 'Coworking App';
    }
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userName: _userName,
          userEmail: _userEmail,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedItemColor: const Color(0xFFB88E2F),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.meeting_room_outlined),
          activeIcon: Icon(Icons.meeting_room),
          label: 'Salas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Reservas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          activeIcon: Icon(Icons.info),
          label: 'Sobre',
        ),
      ],
    );
  }
}