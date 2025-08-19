import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Widget _buildNavItem(String title, Widget screen) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F0ED),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFC4E03B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: const Color(0xff3a86e0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Fin_Buddy",
          style: TextStyle(
            color: const Color(0xff3a86e0),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: const Color(0xff3a86e0)),
            onPressed: () => logoutUser(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.account_circle,
                        size: 80, color: Colors.blue),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name ?? "Nome Usuário",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dob ?? "dd/mm/aaaa",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildNavItem("Minhas Metas", const MetasScreen()),
                  _buildNavItem("Ganhos Fixos", const GanhosFixosScreen()),
                  _buildNavItem("Gastos Fixos", const GastosFixosScreen()),
                  _buildNavItem("Meus Cartões", const CartoesScreen()),
                  _buildNavItem("Tipos de Pagamento",
                      const TiposPagamentosScreen()),
                  _buildNavItem("Categorias", const CategoriasScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
