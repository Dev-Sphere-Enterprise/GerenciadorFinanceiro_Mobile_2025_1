import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/style_constants.dart';
import '../Categorias/categorias_screen.dart';
import '../Cartoes/cartoes_screen.dart';
import '../Gastos/gastos_fixos_screen.dart';
import '../Ganhos/ganhos_fixos_screen.dart';
import '../Login/login_screen.dart';
import '../Metas/metas_screen.dart';
import '../TiposPagamentos/tipos_pagamentos_screen.dart';
import 'dialog/edit_profile_dialog.dart';
import 'viewmodel/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
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
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
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
                              viewModel.user?.nome ?? "Nome Usuário",
                              style: estiloFonteMonospace.copyWith(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => showEditProfileDialog(context),
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
                          viewModel.user?.dob != null
                            ? DateFormat('dd/MM/yyyy').format(viewModel.user!.dob!)
                            : "dd/mm/aaaa",
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
                          title: "Logout",
                          icon: Icons.logout,
                          color: Colors.redAccent,
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirmar Saída"),
                                content: const Text("Você tem certeza que deseja fazer Logout?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Logout", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await viewModel.logout();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
}