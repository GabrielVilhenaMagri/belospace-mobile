import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onProfileTap;
  final List<Widget>? actions;

  const CustomHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onProfileTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      title: SizedBox(
        width: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFB88E2F),
      actions: [
        ...?actions,
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            //
          },
        ),
        const SizedBox(width: 8),
        _buildProfileAvatar(context),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return GestureDetector(
      onTap: onProfileTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navegando para o perfil')),
        );
      },
      child: const CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          color: Color(0xFFB88E2F),
          size: 20,
        ),
      ),
    );
  }
}