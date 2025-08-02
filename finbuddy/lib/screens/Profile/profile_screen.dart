import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Login/login_screen.dart';
import '../Metas/metas_screen.dart';
import '../Ganhos/ganhos_fixos_screen.dart';
import '../Gastos/gastos_fixos_screen.dart';
import '../Cartoes/cartoes_screen.dart';
import '../TiposPagamentos/tipos_pagamentos_screen.dart';
import '../Categorias/categorias_screen.dart';
import 'helpers/profile_helpers.dart';

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
    loadUserData(
      auth: FirebaseAuth.instance,
      firestore: _firestore,
      setLoading: (val) => setState(() => isLoading = val),
      setData: (newName, newDob) => setState(() {
        name = newName;
        dob = newDob;
      }),
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
            onPressed: () => logoutUser(context),
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
                  onPressed: () {
                    editNameAndDob(
                      context: context,
                      firestore: _firestore,
                      auth: FirebaseAuth.instance,
                      currentName: name,
                      currentDob: dob,
                      onUpdated: (newName, newDob) => setState(() {
                        name = newName;
                        dob = newDob;
                      }),
                    );
                  },
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
            _buildNavButton(context, 'Minhas Metas', const MetasScreen()),
            _buildNavButton(context, 'Ganhos Fixos', const GanhosFixosScreen()),
            _buildNavButton(context, 'Gastos Fixos', const GastosFixosScreen()),
            _buildNavButton(context, 'Meus Cartões', const CartoesScreen()),
            _buildNavButton(context, 'Tipos de Pagamentos', const TiposPagamentosScreen()),
            _buildNavButton(context, 'Categorias', const CategoriasScreen()),
          ],
        ),
      ),
    );
  }
}
