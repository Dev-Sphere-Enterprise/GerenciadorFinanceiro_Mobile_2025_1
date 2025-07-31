import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../signin/login_screen.dart';
// import 'metas_screen.dart';
// import 'ganhos_fixos_screen.dart';
// import 'gastos_fixos_screen.dart';
import '../card/cartoes_screen.dart';
// import 'tipos_pagamentos_screen.dart';
// import 'categorias_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? name;
  String? dob;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    setState(() => isLoading = true);

    try {
      final doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final dobTimestamp = data['dob'];

        String formattedDob = '';
        if (dobTimestamp is Timestamp) {
          final date = dobTimestamp.toDate();
          formattedDob =
          "${date.day.toString().padLeft(2, '0')}/"
              "${date.month.toString().padLeft(2, '0')}/"
              "${date.year}";
        } else if (dobTimestamp is String) {
          formattedDob = dobTimestamp;
        }

        setState(() {
          name = data['name'] ?? '';
          dob = formattedDob;
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _editNameAndDob() async {
    final nameController = TextEditingController(text: name ?? '');
    final dobController = TextEditingController(text: dob ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: dobController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Data de Nascimento'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000), // data inicial sugerida
                  firstDate: DateTime(1925),   // data mínima
                  lastDate: DateTime.now(),    // data máxima
                );
                if (pickedDate != null) {
                  dobController.text =
                  "${pickedDate.day.toString().padLeft(2, '0')}/"
                      "${pickedDate.month.toString().padLeft(2, '0')}/"
                      "${pickedDate.year}";
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'name': nameController.text.trim(),
              'dob': dobController.text.trim(),
            }),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        // Converter para Timestamp antes de salvar
        Timestamp? dobTimestamp;
        try {
          final parts = result['dob']!.split('/');
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          dobTimestamp = Timestamp.fromDate(DateTime(year, month, day));
        } catch (_) {
          dobTimestamp = null; // caso a data esteja em formato inválido
        }

        await _firestore.collection('users').doc(user!.uid).update({
          'name': result['name'] ?? '',
          if (dobTimestamp != null) 'dob': dobTimestamp,
        });

        setState(() {
          name = result['name'];
          dob = result['dob'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildNavButton(
      BuildContext context, String title, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${user?.email ?? "Desconhecido"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nome: ${name ?? ""}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editNameAndDob,
                  tooltip: 'Editar Nome e Data de Nascimento',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Data de Nascimento: ${dob ?? ""}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // _buildNavButton(context, 'Minhas Metas', const MetasScreen()),
            // _buildNavButton(context, 'Ganhos Fixos', const GanhosFixosScreen()),
            // _buildNavButton(context, 'Gastos Fixos', const GastosFixosScreen()),
            _buildNavButton(context, 'Meus Cartões', const CartoesScreen()),
            // _buildNavButton(context, 'Tipos de Pagamentos', const TiposPagamentosScreen()),
            // _buildNavButton(context, 'Categorias', const CategoriasScreen()),
          ],
        ),
      ),
    );
  }
}
