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

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

const Color corFundoScaffold = Color(0xFFF0F4F8);
const Color corCardPrincipal = Color(0xFFFAF3DD);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

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

  Widget _buildNavItem(String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0),
            child: Text(
              title,
              style: estiloFonteMonospace.copyWith(fontSize: 18),
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoScaffold,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: finBuddyLime,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: finBuddyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Fin_Buddy",
          style: estiloFonteMonospace.copyWith(
            color: finBuddyBlue,
            fontSize: 22,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  decoration: BoxDecoration(
                    color: corCardPrincipal,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400, width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 90,
                            color: finBuddyBlue,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              name ?? "Nome Usuário",
                              style: estiloFonteMonospace.copyWith(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
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
                              child: Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dob ?? "dd/mm/aaaa",
                          style: estiloFonteMonospace.copyWith(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 30),

                        _buildNavItem(
                          "Minhas Metas",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MetasScreen())),
                        ),
                        _buildNavItem(
                          "Ganhos Fixos",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GanhosFixosScreen())),
                        ),
                        _buildNavItem(
                          "Gastos Fixos",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GastosFixosScreen())),
                        ),
                        _buildNavItem(
                          "Meus Cartões",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartoesScreen())),
                        ),
                        _buildNavItem(
                          "Tipos de Pagamento",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TiposPagamentosScreen())),
                        ),
                        _buildNavItem(
                          "Categorias",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriasScreen())),
                         ),
                        _buildNavItem(
                          "Sair",
                          onTap: () => logoutUser(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}