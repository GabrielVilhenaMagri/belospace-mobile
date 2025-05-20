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
  // Usando constantes para simular dados do usuário (em um app real, viriam de um serviço de autenticação)
  static const String _currentUserId = 'user123';
  static const String _userName = 'João Silva';
  static const String _userEmail = 'joao@exemplo.com';

  // Telas correspondentes a cada aba
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Inicialização das telas com os dados do usuário
    _screens = [
      const RoomsScreen(),
      ReservationsScreen(currentUserId: _currentUserId),
      const AboutScreen(),
    ];
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
    // Usando a rota nomeada para manter consistência na navegação
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: {
        'userName': _userName,
        'userEmail': _userEmail,
      },
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

// Tela Sobre simples
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.business_center,
            size: 80,
            color: Color(0xFFB88E2F),
          ),
          const SizedBox(height: 24),
          const Text(
            'Coworking App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Versão 1.0.0',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Um aplicativo para gerenciamento de reservas de salas de coworking.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 48),
          const Text(
            '© 2025 Coworking App',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}