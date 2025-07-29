// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart'; // Garanta que esta importação esteja presente

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Inicial FinBuddy'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Bem-vindo à Home Screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}