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
const Color corCardPrincipal = Color(0x8BFAF3DD);

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

  Widget _buildNavItem({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color ?? finBuddyBlue, size: 28),
        title: Text(
          title,
          style: estiloFonteMonospace.copyWith(fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: finBuddyDark),
        onTap: onTap,
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
                          title: "Minhas Metas",
                          icon: Icons.flag_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MetasScreen())),
                        ),
                        _buildNavItem(
                          title: "Ganhos Fixos",
                          icon: Icons.attach_money_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GanhosFixosScreen())),
                        ),
                        _buildNavItem(
                          title: "Gastos Fixos",
                          icon: Icons.shopping_cart_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GastosFixosScreen())),
                        ),
                        _buildNavItem(
                          title: "Meus Cartões",
                          icon: Icons.credit_card_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartoesScreen())),
                        ),
                        _buildNavItem(
                          title: "Tipos de Pagamento",
                          icon: Icons.account_balance_wallet_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TiposPagamentosScreen())),
                        ),
                        _buildNavItem(
                          title: "Categorias",
                          icon: Icons.category_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriasScreen())),
                        ),
                        _buildNavItem(
                          title: "Sair",
                          icon: Icons.logout,
                          color: Colors.redAccent,
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